// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {BuyArgs, NFToken, Ray} from "./DataStructure/Objects.sol";
import {Loan, Protocol, Provision, SupplyPosition} from "./DataStructure/Storage.sol";
import {LoanAlreadyRepaid, SupplyPositionDoesntBelongToTheLoan} from "./DataStructure/Errors.sol";
import {RayMath} from "./utils/RayMath.sol";
import {SafeMint} from "./SupplyPositionLogic/SafeMint.sol";
import {protocolStorage, supplyPositionStorage, ONE, ZERO} from "./DataStructure/Global.sol";
import {ERC721CallerIsNotOwnerNorApproved} from "./DataStructure/ERC721Errors.sol";

/// @notice handles sale of collaterals being liquidated, following a dutch auction starting at repayment date
contract AuctionFacet is SafeMint {
    using RayMath for Ray;
    using RayMath for uint256;

    /// @notice a NFT collateral has been sold as part of a liquidation
    /// @param loanId identifier of the loan previously backed by the sold collateral
    event Buy(uint256 indexed loanId);

    /// @notice buy one or multiple NFTs in liquidation
    /// @param args arguments on what and how to buy
    function buy(BuyArgs[] memory args) external {
        for (uint8 i = 0; i < args.length; i++) {
            useLoan(args[i]);
        }
    }

    /// @notice gets the price to buy the underlying collateral of the loan
    /// @param loanId identifier of the loan
    /// @return price computed price
    function price(uint256 loanId) external view returns (uint256) {
        Loan storage loan = protocolStorage().loan[loanId];
        uint256 timeSinceLiquidable = block.timestamp - loan.endDate;
        return price(loan.lent, ONE, timeSinceLiquidable);
    }

    /// @notice handles buying one NFT
    /// @param args arguments on what and how to buy
    function useLoan(BuyArgs memory args) internal {
        // todo #14 cut in multiple functions
        Protocol storage proto = protocolStorage();
        SupplyPosition storage sp = supplyPositionStorage();
        Loan storage loan = proto.loan[args.loanId];
        Ray shareToPay = ONE;

        if (args.to == loan.borrower) {
            loan.payment.borrowerBought = true;
            shareToPay = loan.shareLent;
        }

        uint256 timeSinceLiquidable = block.timestamp - loan.endDate; // reverts if asset is not yet liquidable
        uint256 toPay;
        Provision storage provision;

        if (loan.payment.paid != 0 || loan.payment.liquidated) {
            revert LoanAlreadyRepaid(args.loanId);
        }
        loan.payment.liquidated = true;

        for (uint8 i = 0; i < args.positionIds.length; i++) {
            provision = sp.provision[args.positionIds[i]];
            shareToPay = shareToPay.sub(provision.share);
            if (!_isApprovedOrOwner(msg.sender, args.positionIds[i])) {
                revert ERC721CallerIsNotOwnerNorApproved();
            }
            if (provision.loanId != args.loanId) {
                revert SupplyPositionDoesntBelongToTheLoan(args.positionIds[i], args.loanId);
            }
            _burn(args.positionIds[i]);
        }

        toPay = price(loan.lent, loan.shareLent, timeSinceLiquidable).mul(shareToPay);
        loan.assetLent.transferFrom(msg.sender, address(this), toPay);
        loan.payment.paid = toPay;
        loan.collateral.implem.safeTransferFrom(address(this), args.to, loan.collateral.id);

        emit Buy(args.loanId);
    }

    /// @notice gets price calculated following a linear dutch auction
    /// @param lent amount lent in the loan
    /// @param shareLent share of the loan lent by the caller
    /// @param timeElapsed time elapsed since the collateral is liquidable
    /// @return price computed price
    function price(uint256 lent, Ray shareLent, uint256 timeElapsed) internal view returns (uint256) {
        Protocol storage proto = protocolStorage();

        // todo : explore attack vectors based on small values messing with calculus
        uint256 loanToValue = lent.div(shareLent);
        uint256 initialPrice = loanToValue.mul(proto.auctionPriceFactor);
        Ray decreasingFactor = timeElapsed >= proto.auctionDuration
            ? ZERO
            : ONE.sub(timeElapsed.div(proto.auctionDuration));
        return initialPrice.mul(decreasingFactor);
    }
}
