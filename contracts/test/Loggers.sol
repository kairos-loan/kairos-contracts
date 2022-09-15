// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../DataStructure/Global.sol";
import "forge-std/Test.sol";

/* solhint-disable func-visibility */

function logLoan(Loan memory loan, string memory name) view {
    console.log("~~~~~~~ start loan ", name, " ~~~~~~~");
    console.log("assetLent           ", address(loan.assetLent));
    console.log("lent                ", loan.lent);
    console.log("startDate           ", loan.startDate);
    console.log("endDate             ", loan.endDate);
    console.log("interestPerSecond   ", Ray.unwrap(loan.interestPerSecond));
    console.log("borrower            ", loan.borrower);
    console.log("collateral          ", address(loan.collateral));
    console.log("tokenId             ", loan.tokenId);
    console.log("repaid              ", loan.repaid);
    console.log("liquidated          ", loan.liquidated);
    console.log("borrowerClaimed     ", loan.borrowerClaimed);
    for(uint256 i; i < loan.supplyPositionIds.length; i++) {
        console.log("supplyPositionIds %s: %s", i, loan.supplyPositionIds[i]);
    }
    console.log("~~~~~~~ end loan ", name, "   ~~~~~~~");
}

function logOffer(Offer memory offer, string memory name) view {
    console.log("~~~~~~~ start offer ", name, " ~~~~~~~");
    console.log("assetToLend    ", address(offer.assetToLend));
    console.log("loanToValue    ", offer.loanToValue);
    console.log("duration       ", offer.duration);
    console.log("duration       ", offer.duration);
    console.log("collatSpecType ", uint8(offer.collatSpecType));
    console.log("tranche        ", offer.tranche);
    if (offer.collatSpecType == CollatSpecType.Floor) {
        FloorSpec memory spec = abi.decode(offer.collatSpecs, (FloorSpec));
        console.log("spec implem    ", address(spec.implem));
    } else {
        NFToken memory spec = abi.decode(offer.collatSpecs, (NFToken));
        console.log("spec implem    ", address(spec.implem));
        console.log("spec id        ", spec.id);
    }
    console.log("~~~~~~~ end offer ", name, "   ~~~~~~~");
}

function logProvision(Provision memory provision, string memory name) view {
    console.log("~~~~~~~ start provision ", name, " ~~~~~~~");
    console.log("amount ", provision.amount);
    console.log("share  ", Ray.unwrap(provision.share));
    console.log("loanId ", provision.loanId);
    console.log("~~~~~~~ end provision ", name, "   ~~~~~~~");
}