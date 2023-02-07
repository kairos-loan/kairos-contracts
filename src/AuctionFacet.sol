// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {IAuctionFacet} from "../interface/IAuctionFacet.sol";
import {BuyArg, NFToken, Ray} from "./DataStructure/Objects.sol";
import {Loan, Protocol, Provision, SupplyPosition} from "./DataStructure/Storage.sol";
import {RayMath} from "./utils/RayMath.sol";
import {SafeMint} from "./SupplyPositionLogic/SafeMint.sol";
import {protocolStorage, supplyPositionStorage, ONE, ZERO} from "./DataStructure/Global.sol";
import {ERC20TransferFailed, LoanAlreadyRepaid, SupplyPositionDoesntBelongToTheLoan} from "./DataStructure/Errors.sol";
import {ERC721CallerIsNotOwnerNorApproved} from "./DataStructure/ERC721Errors.sol";

/// @notice handles sale of collaterals being liquidated, following a dutch auction starting at repayment date
contract AuctionFacet is IAuctionFacet, SafeMint {
    using RayMath for Ray;
    using RayMath for uint256;

    /// @notice a NFT collateral has been sold as part of a liquidation
    /// @param loanId identifier of the loan previously backed by the sold collateral
    /// @param args arguments NFT sold
    event Buy(uint256 indexed loanId, bytes args);

    /// @notice buy one or multiple NFTs in liquidation
    /// @param args arguments on what and how to buy
    function buy(BuyArg[] memory args) external {
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
    function useLoan(BuyArg memory args) internal {
        Loan storage loan = protocolStorage().loan[args.loanId];
        uint256 timeSinceLiquidable = block.timestamp - loan.endDate; // reverts if asset is not yet liquidable

        if (loan.payment.paid != 0 || loan.payment.liquidated) {
            revert LoanAlreadyRepaid(args.loanId);
        }
        loan.payment.liquidated = true;

        uint256 toPay = price(loan.lent, getShareToPay(args, loan), timeSinceLiquidable);
        if (!loan.assetLent.transferFrom(msg.sender, address(this), toPay)) {
            revert ERC20TransferFailed(loan.assetLent, msg.sender, address(this));
        }
        loan.payment.paid = toPay;
        loan.collateral.implem.safeTransferFrom(address(this), args.to, loan.collateral.id);

        emit Buy(args.loanId, abi.encode(args));
    }

    /// @notice computes the share of the NFT to pay and burns the used supply positions
    /// @param args arguments on what and how to buy
    /// @param loan loan to buy collateral from
    /// @return shareToPay share of the loan to pay
    function getShareToPay(BuyArg memory args, Loan storage loan) internal returns (Ray shareToPay) {
        SupplyPosition storage sp = supplyPositionStorage();
        Provision storage provision;
        shareToPay = ONE;
        if (args.to == loan.borrower) {
            loan.payment.borrowerBought = true;
            shareToPay = loan.shareLent;
        }

        for (uint8 i = 0; i < args.positionIds.length; i++) {
            uint256 positionId = args.positionIds[i];
            provision = sp.provision[positionId];
            if (!_isApprovedOrOwner(msg.sender, positionId)) {
                revert ERC721CallerIsNotOwnerNorApproved();
            }
            if (provision.loanId != args.loanId) {
                revert SupplyPositionDoesntBelongToTheLoan(positionId, args.loanId);
            }
            shareToPay = shareToPay.sub(provision.share);
            _burn(positionId);
        }
    }

    /// @notice gets price calculated following a linear dutch auction
    /// @param lent total amount lent in the loan
    /// @param shareToPay share of the collateral to pay, I.e share of the loan not owned by caller
    /// @param timeElapsed time elapsed since the collateral is liquidable
    /// @return price computed price
    function price(uint256 lent, Ray shareToPay, uint256 timeElapsed) internal view returns (uint256) {
        Protocol storage proto = protocolStorage();

        // todo : explore attack vectors based on small values messing with calculus
        Ray decreasingFactor = timeElapsed >= proto.auctionDuration
            ? ZERO
            : ONE.sub(timeElapsed.div(proto.auctionDuration));
        uint256 totalToPay = lent.mul(proto.auctionPriceFactor).mul(decreasingFactor);
        return totalToPay.mul(shareToPay);
    }
}
