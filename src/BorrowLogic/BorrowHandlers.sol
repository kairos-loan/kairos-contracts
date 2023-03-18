// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IBorrowHandlers} from "../interface/IBorrowHandlers.sol";

import {BorrowCheckers} from "./BorrowCheckers.sol";
import {CollateralState, NFToken, OfferArg, Ray} from "../DataStructure/Objects.sol";
import {Loan, Payment, Protocol, Provision, Auction} from "../DataStructure/Storage.sol";
import {ONE, protocolStorage, supplyPositionStorage} from "../DataStructure/Global.sol";
import {RayMath} from "../utils/RayMath.sol";
import {Erc20CheckedTransfer} from "../utils/Erc20CheckedTransfer.sol";
import {SafeMint} from "../SupplyPositionLogic/SafeMint.sol";
/* solhint-disable-next-line max-line-length */
import {InconsistentAssetRequests, InconsistentTranches, RequestedAmountTooHigh, UnsafeAmountLent, UnsafeOfferLoanToValuesGap} from "../DataStructure/Errors.sol";

/// @notice handles usage of entities to borrow with
abstract contract BorrowHandlers is IBorrowHandlers, BorrowCheckers, SafeMint {
    using RayMath for uint256;
    using RayMath for Ray;
    using Erc20CheckedTransfer for IERC20;

    /// @notice handles usage of a loan offer to borrow from
    /// @param arg arguments for the usage of this offer
    /// @param collatState tracked state of the matching of the collateral
    /// @return collateralState updated `collatState` after usage of the offer
    function useOffer(
        OfferArg memory arg,
        CollateralState memory collatState
    ) internal returns (CollateralState memory) {
        address signer = checkOfferArg(arg);
        Ray shareMatched;

        if (arg.offer.assetToLend != collatState.assetLent) {
            // all offers used for a collateral must refer to the same erc20
            revert InconsistentAssetRequests(collatState.assetLent, arg.offer.assetToLend);
        }
        if (arg.offer.tranche != collatState.tranche) {
            // all offers used for a collateral must refer to the same interest rate tranche
            revert InconsistentTranches(collatState.tranche, arg.offer.tranche);
        }

        checkCollateral(arg.offer, collatState.nft);

        // we keep track of the share of the maximum value (`loanToValue`) proposed by an offer used by the borrower.
        shareMatched = arg.amount.div(arg.offer.loanToValue);
        collatState.matched = collatState.matched.add(shareMatched);

        /* we consider that lenders are acquiring shares of the NFT used as collateral by lending the amount
        corresponding to shareMatched. We check this process is not ditributing more shares than the full NFT value. */
        if (collatState.matched.gt(ONE)) {
            revert RequestedAmountTooHigh(
                arg.amount,
                arg.offer.loanToValue.mul(ONE.sub(collatState.matched.sub(shareMatched))),
                arg.offer
            );
        }

        // the shortest duration offered among all offers used will be used to determine the loan end date.
        if (arg.offer.duration < collatState.minOfferDuration) {
            collatState.minOfferDuration = arg.offer.duration;
        }
        if (arg.offer.loanToValue < collatState.minOfferLoanToValue) {
            collatState.minOfferLoanToValue = arg.offer.loanToValue;
        }
        if (arg.offer.loanToValue > collatState.maxOfferLoanToValue) {
            collatState.maxOfferLoanToValue = arg.offer.loanToValue;
        }

        /* This check serves to prevent a manipulation of the auction start price. The auction price is determined by
        a multiple of the mean of the offer loanToValues used in the loan. Being lender and borrower at the same time,
        one could influence this price by providing an infinitesimal loanToValue price, get a loan instantly liquidable
        at a price inferior a the loanToValue of another offer used in the loan. buying its own NFT in auction would
        result in a net gain arising from the difference between the sale price of the NFT and the loanToValue provided
        by the other offer (effectively stealing the funds of the lender). This is prevented by limiting the max gap
        between two offer loanToValue to a factor 2, and making the priceFactor of the auction equal or superior to 2.5.
        In the worst case, the attacker can influence the start price of the auction to be
        (attacked_offer_ltv / 2) * 2.5 which is superior to the attacked offer loan to value. */
        if (collatState.maxOfferLoanToValue > collatState.minOfferLoanToValue * 2) {
            revert UnsafeOfferLoanToValuesGap(
                collatState.minOfferLoanToValue,
                collatState.maxOfferLoanToValue
            );
        }

        // transferring the borrowed funds from the lender to the borrower
        collatState.assetLent.checkedTransferFrom(signer, collatState.from, arg.amount);

        // issuing supply position NFT to the signer of the loan offer with metadatas
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
        CollateralState memory collatState = initializedCollateralState(args[0], from, nft);

        // total supply is later incremented as part of the minting of the first supply position
        uint256 firstSupplyPositionId = supplyPositionStorage().totalSupply + 1;
        uint256 nbOfOffers = args.length;
        uint256 lent; // keep track of the total amount lent/borrowed

        for (uint256 i = 0; i < nbOfOffers; i++) {
            collatState = useOffer(args[i], collatState);
            lent += args[i].amount;
        }

        // cf RepayFacet for the rationale of this check. We prevent repaying being impossible due to an overflow in the
        // interests to repay calculation.
        if (lent > 1e40) {
            revert UnsafeAmountLent(lent);
        }
        loan = initializedLoan(collatState, from, nft, nbOfOffers, lent, firstSupplyPositionId);
        protocolStorage().loan[collatState.loanId] = loan;

        emit Borrow(collatState.loanId, abi.encode(loan));
    }

    /// @notice initializes the collateral state memory struct used to keep track of the collateralization and other
    ///     health checks variables during the issuance of a loan
    /// @param firstOfferArg the first struct of arguments for an offer among potentially multiple used loan offers
    /// @param from I.e borrower
    /// @param nft - used as collateral
    /// @return collatState the initialized collateral state struct
    function initializedCollateralState(
        OfferArg memory firstOfferArg,
        address from,
        NFToken memory nft
    ) internal returns (CollateralState memory) {
        return
            CollateralState({
                matched: Ray.wrap(0),
                assetLent: firstOfferArg.offer.assetToLend,
                tranche: firstOfferArg.offer.tranche,
                minOfferDuration: firstOfferArg.offer.duration,
                minOfferLoanToValue: firstOfferArg.offer.loanToValue,
                maxOfferLoanToValue: firstOfferArg.offer.loanToValue,
                from: from,
                nft: nft,
                loanId: ++protocolStorage().nbOfLoans // returns incremented value (also increments in storage)
            });
    }

    /// @notice initializes the loan struct representing borrowed funds from one NFT collateral, will be stored
    /// @param collatState contains info on share of the collateral value used by the borrower
    /// @param nft - used as collateral
    /// @param nbOfOffers number of loan offers used (I.e number of supply positions minted)
    /// @param lent amount lent/borrowed
    /// @param firstSupplyPositionId identifier of the first supply position (I.e NFT token id)
    /// @return loan tne initialized loan to store
    function initializedLoan(
        CollateralState memory collatState,
        address from,
        NFToken memory nft,
        uint256 nbOfOffers,
        uint256 lent,
        uint256 firstSupplyPositionId
    ) internal view returns (Loan memory) {
        Protocol storage proto = protocolStorage();

        /* the shortest offered duration determines the max date of repayment to make sure all loan offer terms are
        respected */
        uint256 endDate = block.timestamp + collatState.minOfferDuration;
        Payment memory notPaid; // not paid as it corresponds to the meaning of the uninitialized struct

        /* the minimum interests amount to repay is used as anti ddos mechanism to prevent borrowers to produce lots of
        dust supply positions that the lenders will have to pay gas to claim. This is why it is determined on a
        per-offer basis, as each position can be used to claim funds separetely and induce a gas cost. With a design
        approach similar to the auction parameters setting, this minimal cost is set at borrow time to avoid bad
        surprises arising from governance setting new parameters during the loan life. cf docs for more details. */
        notPaid.minInterestsToRepay = nbOfOffers * proto.minOfferCost[collatState.assetLent];

        return
            Loan({
                assetLent: collatState.assetLent,
                lent: lent,
                shareLent: collatState.matched,
                startDate: block.timestamp,
                endDate: endDate,
                /* auction parameters are copied from protocol parameters to the loan storage as a way to prevent
                a governance-initiated change of terms to modify the terms a borrower chose to accept or change the
                price of an NFT being sold abruptly during the course of an auction. */
                auction: Auction({duration: proto.auction.duration, priceFactor: proto.auction.priceFactor}),
                /* the interest rate is stored as a value instead of the tranche id as a precaution in case of a change
                in the interest rate mechanisms due to contract upgrade */
                interestPerSecond: proto.tranche[collatState.tranche],
                borrower: from,
                collateral: nft,
                supplyPositionIndex: firstSupplyPositionId,
                payment: notPaid,
                /* from the first supply position id and the number of offers used all supply position ids can be
                deduced + the number of offers/positions is directly accessible for other purposes */
                nbOfPositions: nbOfOffers
            });
    }
}
