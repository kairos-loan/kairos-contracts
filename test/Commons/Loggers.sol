// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {console} from "forge-std/console.sol";
import {Test} from "forge-std/Test.sol";

import {CollateralState, Offer, Ray, NFToken} from "../../src/DataStructure/Objects.sol";
import {Loan, Provision, Auction, Payment} from "../../src/DataStructure/Storage.sol";

contract Loggers is Test {
    function logLoan(Loan memory loan, string memory name) internal view {
        console.log("~~~~~~~ start loan ", name, " ~~~~~~~");
        console.log("assetLent           ", address(loan.assetLent));
        console.log("lent                ", loan.lent);
        console.log("shareLent           ", Ray.unwrap(loan.shareLent));
        console.log("startDate           ", loan.startDate);
        console.log("endDate             ", loan.endDate);
        logAuction(true, loan.auction);
        console.log("interestPerSecond   ", Ray.unwrap(loan.interestPerSecond));
        console.log("borrower            ", loan.borrower);
        logNft("collateral.", loan.collateral);
        logPayment(true, loan.payment);
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
        console.log("matched          ", Ray.unwrap(collat.matched));
        console.log("minOfferDuration ", collat.minOfferDuration);
        console.log("from             ", collat.from);
        console.log("nft.id           ", collat.nft.id);
        console.log("loanId           ", collat.loanId);
        console.log("~~~~~~~ end Collateral State ", name, "   ~~~~~~~");
    }

    function logNft(NFToken memory nft, string memory name) internal view {
        console.log("~~~~~~~ start NFT ", name, " ~~~~~~~");
        logNft("", nft);
        console.log("~~~~~~~ end NFT ", name, "   ~~~~~~~");
    }

    function logNft(string memory prefix, NFToken memory nft) internal view {
        console.log("%simplem    %s", prefix, address(nft.implem));
        console.log("%sid        %s", prefix, nft.id);
    }

    function logPayment(Payment memory payment, string memory name) internal view {
        console.log("~~~~~~~ start Payment ", name, " ~~~~~~~");
        logPayment(false, payment);
        console.log("~~~~~~~ end Payment ", name, "   ~~~~~~~");
    }

    function logPayment(bool prefixed, Payment memory payment) internal view {
        string memory prefix = prefixed ? "payment." : "";
        console.log("%spaid         %s", prefix, payment.paid);
        console.log("%sliquidated   %s", prefix, payment.liquidated);
        console.log("%sborrClaimed  %s", prefix, payment.borrowerClaimed);
        console.log("%sborrBought   %s", prefix, payment.borrowerClaimed);
    }

    function logAuction(Auction memory auction, string memory name) internal view {
        console.log("~~~~~~~ start Auction ", name, " ~~~~~~~");
        logAuction(false, auction);
        console.log("~~~~~~~ end Auction ", name, "   ~~~~~~~");
    }

    function logAuction(bool prefixed, Auction memory auction) internal view {
        if (prefixed) {
            console.log("auction.duration    ", auction.duration);
            console.log("auction.priceFactor ", Ray.unwrap(auction.priceFactor));
        } else {
            console.log("duration    ", auction.duration);
            console.log("priceFactor ", Ray.unwrap(auction.priceFactor));
        }
    }
}
