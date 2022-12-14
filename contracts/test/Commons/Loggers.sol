// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../../src/DataStructure/Global.sol";
import "forge-std/Test.sol";

contract Loggers is Test {
    function logLoan(Loan memory loan, string memory name) internal view {
        console.log("~~~~~~~ start loan ", name, " ~~~~~~~");
        console.log("assetLent           ", address(loan.assetLent));
        console.log("lent                ", loan.lent);
        console.log("startDate           ", loan.startDate);
        console.log("endDate             ", loan.endDate);
        console.log("interestPerSecond   ", Ray.unwrap(loan.interestPerSecond));
        console.log("borrower            ", loan.borrower);
        console.log("collat implem       ", address(loan.collateral.implem));
        console.log("collat id           ", loan.collateral.id);
        console.log("paid                ", loan.payment.paid);
        console.log("liquidated          ", loan.payment.liquidated);
        console.log("borrowerClaimed     ", loan.payment.borrowerClaimed);
        console.log("borrowerBought      ", loan.payment.borrowerBought);
        console.log("supplyPositionIndex:");
        if (loan.nbOfPositions >= 2) {
            console.log(
                "from %s to %s",
                loan.supplyPositionIndex,
                loan.supplyPositionIndex + loan.nbOfPositions - 1
            );
        } else {
            console.log("position ", loan.supplyPositionIndex);
        }
        console.log("~~~~~~~ end loan ", name, "   ~~~~~~~");
    }

    function logOffer(Offer memory offer, string memory name) internal view {
        console.log("~~~~~~~ start offer ", name, " ~~~~~~~");
        console.log("assetToLend    ", address(offer.assetToLend));
        console.log("loanToValue    ", offer.loanToValue);
        console.log("duration       ", offer.duration);
        console.log("expirationDate ", offer.expirationDate);
        console.log("tranche        ", offer.tranche);
        console.log("collat implem  ", address(offer.collateral.implem));
        console.log("collat id      ", offer.collateral.id);
        console.log("~~~~~~~ end offer ", name, "   ~~~~~~~");
    }

    function logProvision(Provision memory provision, string memory name) internal view {
        console.log("~~~~~~~ start provision ", name, " ~~~~~~~");
        console.log("amount ", provision.amount);
        console.log("share  ", Ray.unwrap(provision.share));
        console.log("loanId ", provision.loanId);
        console.log("~~~~~~~ end provision ", name, "   ~~~~~~~");
    }

    function logCollateralState(CollateralState memory collat, string memory name) internal view {
        console.log("~~~~~~~ start Collateral State ", name, " ~~~~~~~");
        console.log("matched   ", Ray.unwrap(collat.matched));
        console.log("matched   ", collat.minOfferDuration);
        console.log("matched   ", collat.from);
        console.log("matched   ", collat.nft.id);
        console.log("matched   ", collat.loanId);
        console.log("~~~~~~~ end Collateral ", name, "   ~~~~~~~");
    }


}
