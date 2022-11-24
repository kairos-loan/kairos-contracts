// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./BorrowCheckers.sol";
import "../utils/RayMath.sol";
import "../SupplyPositionFacet.sol";
import "../SupplyPositionLogic/SafeMint.sol";

/// @notice handles usage of entities to borrow with
abstract contract BorrowHandlers is BorrowCheckers, SafeMint {
    using RayMath for uint256;
    using RayMath for Ray;

    /// @notice handles usage of a loan offer to borrow from
    /// @param args arguments for the usage of this offer
    /// @param collatState tracked state of the matching of the collateral
    /// @return collateralState updated `collatState` after usage of the offer
    function useOffer(
        OfferArgs memory args,
        CollateralState memory collatState
    ) internal returns (CollateralState memory) {
        address signer = checkOfferArgs(args);
        Ray shareMatched;

        if (args.offer.assetToLend != collatState.assetLent) {
            // all offers used for a collateral must refer to the same erc20
            revert InconsistentAssetRequests(collatState.assetLent, args.offer.assetToLend);
        }

        checkCollateral(args.offer, collatState.nft);
        shareMatched = args.amount.div(args.offer.loanToValue);
        collatState.matched = collatState.matched.add(shareMatched);

        if (collatState.matched.gt(ONE)) {
            revert RequestedAmountTooHigh(
                args.amount,
                args.offer.loanToValue - args.offer.loanToValue.mul(collatState.matched)
            );
        }
        if (args.offer.duration < collatState.minOfferDuration) {
            collatState.minOfferDuration = args.offer.duration;
        }

        collatState.assetLent.transferFrom(signer, collatState.from, args.amount);
        safeMint(signer, Provision({amount: args.amount, share: shareMatched, loanId: collatState.loanId}));
        return (collatState);
    }

    /// @notice handles usage of one collateral to back a loan request
    /// @param args arguments for usage of one or multiple loan offers
    /// @param from borrower for this loan
    /// @param nft collateral to use
    /// @return loan the loan created backed by provided collateral
    function useCollateral(
        OfferArgs[] memory args,
        address from,
        NFToken memory nft
    ) internal returns (Loan memory loan) {
        Protocol storage proto = protocolStorage();
        uint256 lent;
        uint256 supplyPositionIndex = supplyPositionStorage().totalSupply + 1;
        CollateralState memory collatState = CollateralState({
            matched: Ray.wrap(0),
            assetLent: args[0].offer.assetToLend,
            minOfferDuration: type(uint256).max,
            from: from,
            nft: nft,
            loanId: ++proto.nbOfLoans
        });
        for (uint8 i; i < args.length; i++) {
            collatState = useOffer(args[i], collatState);
            lent += args[i].amount;
        }
        Payment memory notPaid;
        loan = Loan({
            assetLent: collatState.assetLent,
            lent: lent,
            shareLent: collatState.matched,
            startDate: block.timestamp,
            endDate: block.timestamp + collatState.minOfferDuration,
            interestPerSecond: proto.tranche[0], // todo #27 adapt rate to the offers
            borrower: from,
            collateral: nft,
            supplyPositionIndex: supplyPositionIndex,
            payment: notPaid,
            nbOfPositions: uint8(args.length)
        });
        proto.loan[collatState.loanId] = loan;
    }
}
