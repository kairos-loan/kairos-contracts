// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "./BorrowCheckers.sol";
import "../utils/RayMath.sol";
import "../SupplyPositionFacet.sol";

// todo : docs

abstract contract BorrowHandlers is BorrowCheckers {
    using RayMath for uint256;
    using RayMath for Ray;

    function useOffer(
        OfferArgs memory args,
        CollateralState memory collatState
    ) internal returns(
        uint256 supplyPositionId, 
        CollateralState memory
    ) {
        address signer = checkOfferArgs(args);
        Ray shareMatched;

        if (args.offer.assetToLend != collatState.assetLent) {
            // all offers used for a collateral must refer to the same erc20
            revert InconsistentAssetRequests(collatState.assetLent, args.offer.assetToLend);
        }

        checkCollatSpecs(collatState.nft.implem, collatState.nft.id, args.offer);
        shareMatched = args.amount.divToRay(args.offer.loanToValue);
        collatState.matched = collatState.matched.add(shareMatched);

        if (collatState.matched.gt(ONE)) {
            revert RequestedAmountTooHigh(
                args.amount, 
                args.offer.loanToValue - args.offer.loanToValue.mul(collatState.matched));
        }
        if (args.offer.duration < collatState.minOfferDuration) {collatState.minOfferDuration = args.offer.duration;}

        collatState.assetLent.transferFrom(signer, collatState.from, args.amount);

        return(SupplyPositionFacet(address(this)).safeMint(signer, Provision({
            amount: args.amount,
            share: shareMatched
        })), collatState);
    }

    function useCollateral(
        OfferArgs[] memory args, 
        address from, 
        NFToken memory nft
    ) internal returns(Loan memory loan) {
        uint256[] memory supplyPositionIds = new uint256[](args.length);
        CollateralState memory collatState = CollateralState({
            matched: Ray.wrap(0),
            assetLent: args[0].offer.assetToLend,
            minOfferDuration: type(uint256).max,
            from: from,
            nft: nft
        });
        uint256 lent;

        for(uint8 i; i < args.length; i++) {
            (supplyPositionIds[i], collatState) = useOffer(args[i], collatState);
            lent += args[i].amount;
        }

        loan = Loan({
            assetLent: collatState.assetLent,
            lent: lent,
            endDate: block.timestamp + collatState.minOfferDuration,
            tranche: 0, // will change in future implem
            borrower: from,
            collateral: IERC721(msg.sender),
            tokenId: nft.id,
            supplyPositionIds : supplyPositionIds
        });
    }
}