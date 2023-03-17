// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IAuctionFacet} from "./interface/IAuctionFacet.sol";

import {BuyArg, NFToken, Ray} from "./DataStructure/Objects.sol";
import {Loan, Protocol, Provision, SupplyPosition} from "./DataStructure/Storage.sol";
import {RayMath} from "./utils/RayMath.sol";
import {Erc20CheckedTransfer} from "./utils/Erc20CheckedTransfer.sol";
import {SafeMint} from "./SupplyPositionLogic/SafeMint.sol";
import {protocolStorage, supplyPositionStorage, ONE, ZERO} from "./DataStructure/Global.sol";
// solhint-disable-next-line max-line-length
import {LoanAlreadyRepaid, CollateralIsNotLiquidableYet} from "./DataStructure/Errors.sol";

/// @notice handles sale of collaterals being liquidated, following a dutch auction starting at repayment date
contract AuctionFacet is IAuctionFacet, SafeMint {
    using RayMath for Ray;
    using RayMath for uint256;
    using Erc20CheckedTransfer for IERC20;

    /// @notice buy one or multiple NFTs in liquidation
    /// @param args arguments on what and how to buy
    function buy(BuyArg[] memory args) external {
        for (uint256 i = 0; i < args.length; i++) {
            useLoan(args[i]);
        }
    }

    /// @notice gets the price to buy the underlying collateral of the loan
    /// @param loanId identifier of the loan
    /// @return price computed price
    function price(uint256 loanId) public view returns (uint256) {
        // todo test price
        Loan storage loan = protocolStorage().loan[loanId];
        uint256 loanEndDate = loan.endDate;
        if (block.timestamp < loanEndDate) {
            revert CollateralIsNotLiquidableYet(loanEndDate, loanId);
        }
        uint256 timeSinceLiquidable = block.timestamp - loanEndDate;
        Ray decreasingFactor = timeSinceLiquidable >= loan.auction.duration
            ? ZERO
            : ONE.sub(timeSinceLiquidable.div(loan.auction.duration));
        uint256 estimatedValue = loan.lent.mul(ONE.div(loan.shareLent));
        return estimatedValue.mul(loan.auction.priceFactor).mul(decreasingFactor);
    }

    /// @notice handles buying one NFT
    /// @param arg arguments on what and how to buy
    function useLoan(BuyArg memory arg) internal {
        Loan storage loan = protocolStorage().loan[arg.loanId];

        if (block.timestamp < loan.endDate) {
            revert CollateralIsNotLiquidableYet(loan.endDate, arg.loanId);
        }
        if (loan.payment.paid != 0 || loan.payment.liquidated) {
            revert LoanAlreadyRepaid(arg.loanId);
        }
        loan.payment.liquidated = true;
        uint256 toPay = price(arg.loanId);
        loan.payment.paid = toPay;
        loan.assetLent.checkedTransferFrom(msg.sender, address(this), toPay);
        loan.collateral.implem.safeTransferFrom(address(this), arg.to, loan.collateral.id);

        emit Buy(arg.loanId, abi.encode(arg));
    }
}
