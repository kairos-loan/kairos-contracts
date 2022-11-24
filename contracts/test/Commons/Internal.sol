// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./TestCommons.sol";
import "./BigKairos.sol";

contract Internal is TestCommons, BigKairos {
    using RayMath for Ray;

    constructor() {
        protocolStorage().tranche[0] = ONE.div(10).mul(4).div(365 days); // 40% APR
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
