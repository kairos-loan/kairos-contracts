// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./TestCommons.sol";
import "./BigKairos.sol";

contract Internal is TestCommons, BigKairos {
    using RayMath for Ray;

    constructor() {
        bytes memory randoCode = hex"01";

        protocolStorage().tranche[0] = ONE.div(10).mul(4).div(365 days); // 40% APR
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
        OfferArgs memory args,
        CollateralState memory collatState
    ) external returns (CollateralState memory) {
        return useOffer(args, collatState);
    }

    function checkOfferArgsExternal(OfferArgs memory args) external view returns (address) {
        return checkOfferArgs(args);
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
