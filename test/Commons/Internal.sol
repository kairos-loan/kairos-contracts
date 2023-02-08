// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {BigKairos} from "./BigKairos.sol";
import {CollateralState, NFToken, Offer, OfferArg, Ray} from "../../src/DataStructure/Objects.sol";
import {Loan, Protocol, Provision} from "../../src/DataStructure/Storage.sol";
import {Money} from "../../src/mock/Money.sol";
import {NFT} from "../../src/mock/NFT.sol";
import {protocolStorage, ONE} from "../../src/DataStructure/Global.sol";
import {RayMath} from "../../src/utils/RayMath.sol";
import {TestCommons} from "./TestCommons.sol";

/// @dev inherit from this contract to perform tests from INSIDE kairos
contract Internal is TestCommons, BigKairos {
    using RayMath for Ray;

    constructor() {
        bytes memory randoCode = hex"01";
        Protocol storage proto = protocolStorage();
        proto.tranche[0] = ONE.div(10).mul(4).div(365 days); // 40% APR
        proto.auctionPriceFactor = ONE.mul(3);
        proto.auctionDuration = 3 days;
        money = Money(address(bytes20(keccak256("mock address money"))));
        vm.etch(address(money), randoCode);
        vm.label(address(money), "money");
        money2 = Money(address(bytes20(keccak256("mock address money2"))));
        vm.etch(address(money2), randoCode);
        vm.label(address(money2), "money2");
        nft = NFT(address(bytes20(keccak256("mock address nft"))));
        vm.etch(address(nft), randoCode);
        vm.label(address(nft), "nft");
        nft2 = NFT(address(bytes20(keccak256("mock address nft2"))));
        vm.etch(address(nft2), randoCode);
        vm.label(address(nft2), "nft2");
    }

    function useOfferExternal(
        OfferArg memory arg,
        CollateralState memory collatState
    ) external returns (CollateralState memory) {
        return useOffer(arg, collatState);
    }

    function useCollateralExternal(
        OfferArg[] memory args,
        address from,
        NFToken memory nft
    ) external returns (Loan memory) {
        return useCollateral(args, from, nft);
    }

    function checkOfferArgExternal(OfferArg memory arg) external view returns (address) {
        return checkOfferArg(arg);
    }

    function priceExternal(uint256 lent, Ray shareLent, uint256 timeElapsed) external view returns (uint256) {
        return price(lent, shareLent, timeElapsed);
    }

    function checkCollateralExternal(Offer memory offer, NFToken memory providedNft) external pure {
        checkCollateral(offer, providedNft);
    }

    function sendInterestsExternal(
        Loan storage loan,
        Provision storage provision
    ) internal returns (uint256) {
        return sendInterests(loan, provision);
    }

    function sendShareOfSaleAsSupplierExternal(
        Loan storage loan,
        Provision storage provision
    ) internal returns (uint256) {
        return sendShareOfSaleAsSupplier(loan, provision);
    }

    function sentInterestsIn(Loan storage loan, Provision storage provision) internal returns (uint256) {
        return sendInterests(loan, provision);
    }

    /// @dev use only in TestCommons
    function getOfferDigest(Offer memory offer) internal view override returns (bytes32) {
        return offerDigest(offer);
    }

    /// @dev use only in TestCommons
    function getTranche(uint256 trancheId) internal view override returns (Ray rate) {
        return protocolStorage().tranche[trancheId];
    }
}
