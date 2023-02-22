// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {IBorrowHandlers} from "../interface/IBorrowHandlers.sol";

import {BorrowCheckers} from "./BorrowCheckers.sol";
import {CollateralState, NFToken, OfferArg, Ray} from "../DataStructure/Objects.sol";
import {Loan, Payment, Protocol, Provision, Auction} from "../DataStructure/Storage.sol";
import {ONE, protocolStorage, supplyPositionStorage} from "../DataStructure/Global.sol";
import {RayMath} from "../utils/RayMath.sol";
import {SafeMint} from "../SupplyPositionLogic/SafeMint.sol";
/* solhint-disable-next-line max-line-length */
import {ERC20TransferFailed, InconsistentAssetRequests, InconsistentTranches, RequestedAmountIsNull, RequestedAmountTooHigh, InvalidTranche} from "../DataStructure/Errors.sol";

/// @notice handles usage of entities to borrow with
abstract contract BorrowHandlers is IBorrowHandlers, BorrowCheckers, SafeMint {
    using RayMath for uint256;
    using RayMath for Ray;

    /// @notice handles usage of a loan offer to borrow from
    /// @param arg arguments for the usage of this offer
    /// @param collatState tracked state of the matching of the collateral
    /// @return collateralState updated `collatState` after usage of the offer
    function useOffer(
        OfferArg memory arg,
        CollateralState memory collatState
    ) internal returns (CollateralState memory) {
        Protocol storage proto = protocolStorage();

        address signer = checkOfferArg(arg);
        Ray shareMatched;

        if (arg.offer.assetToLend != collatState.assetLent) {
            // all offers used for a collateral must refer to the same erc20
            revert InconsistentAssetRequests(collatState.assetLent, arg.offer.assetToLend);
        }
        if (arg.offer.tranche != collatState.tranche) {
            revert InconsistentTranches(collatState.tranche, arg.offer.tranche);
        }
        if (arg.amount == 0) {
            revert RequestedAmountIsNull(arg.offer);
        }

        checkCollateral(arg.offer, collatState.nft);
        shareMatched = arg.amount.div(arg.offer.loanToValue);
        collatState.matched = collatState.matched.add(shareMatched);

        if (collatState.matched.gt(ONE)) {
            revert RequestedAmountTooHigh(
                arg.amount,
                arg.offer.loanToValue.mul(ONE.sub(collatState.matched.sub(shareMatched))),
                arg.offer
            );
        }
        if (arg.offer.duration < collatState.minOfferDuration) {
            collatState.minOfferDuration = arg.offer.duration;
        }
        if (arg.offer.tranche >= proto.nbOfTranches) {
            revert InvalidTranche(proto.nbOfTranches);
        }
        if (!collatState.assetLent.transferFrom(signer, collatState.from, arg.amount)) {
            revert ERC20TransferFailed(collatState.assetLent, signer, collatState.from);
        }

        safeMint(signer, Provision({amount: arg.amount, share: shareMatched, loanId: collatState.loanId}));
        return (collatState);
    }

    /// @notice handles usage of one collateral to back a loan request
    /// @param args arguments for usage of one or multiple loan offers
    /// @param from borrower for this loan
    /// @param nft collateral to use
    /// @return loan the loan created backed by provided collateral
    function useCollateral(
        OfferArg[] memory args,
        address from,
        NFToken memory nft
    ) internal returns (Loan memory loan) {
        Protocol storage proto = protocolStorage();
        uint256 lent;
        uint256 supplyPositionIndex = supplyPositionStorage().totalSupply + 1;
        CollateralState memory collatState = CollateralState({
            matched: Ray.wrap(0),
            assetLent: args[0].offer.assetToLend,
            tranche: args[0].offer.tranche,
            minOfferDuration: type(uint256).max,
            from: from,
            nft: nft,
            loanId: ++proto.nbOfLoans // returns incremented value (also increments in storage)
        });
        for (uint8 i = 0; i < args.length; i++) {
            collatState = useOffer(args[i], collatState);
            lent += args[i].amount;
        }
        Payment memory notPaid;
        uint256 endDate = block.timestamp + collatState.minOfferDuration;
        loan = Loan({
            assetLent: collatState.assetLent,
            lent: lent,
            shareLent: collatState.matched,
            startDate: block.timestamp,
            endDate: endDate,
            auction: Auction({duration: proto.auction.duration, priceFactor: proto.auction.priceFactor}),
            interestPerSecond: proto.tranche[collatState.tranche],
            borrower: from,
            collateral: nft,
            supplyPositionIndex: supplyPositionIndex,
            payment: notPaid,
            nbOfPositions: uint8(args.length)
        });
        proto.loan[collatState.loanId] = loan;
        emit Borrow(collatState.loanId, abi.encode(loan));
    }
}
