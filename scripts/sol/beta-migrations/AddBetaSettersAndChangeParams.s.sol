// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {Script} from "forge-std/Script.sol";
import {IKairos} from "../../../src/interface/IKairos.sol";
import {IDiamond} from "diamond/contracts/interfaces/IDiamond.sol";
import {claimFS, auctionFS} from "../../../src/utils/FuncSelectors.h.sol";
import {BetaSettersFacet} from "../../../src/BetaSettersFacet.sol";
import {Ray} from "../../../src/DataStructure/Objects.sol";
import {ONE} from "../../../src/DataStructure/Global.sol";
import {RayMath} from "../../../src/utils/RayMath.sol";

/* solhint-disable-next-line func-visibility */
function betaSettersFS() pure returns (bytes4[] memory) {
    bytes4[] memory functionSelectors = new bytes4[](1);

    functionSelectors[0] = BetaSettersFacet.setAprAndAuctionDuration.selector;

    return functionSelectors;
}

// for goerli adding two missing facets
contract AddDeployedFacets is Script {
    using RayMath for Ray;

    function run() public {
        uint256 deployerKey = vm.envUint("DEPLOYER_KEY");
        bytes memory emptyBytes;
        uint256 oneBetaDay = 5 * 24; // in seconds
        uint256 oneBetaYear = oneBetaDay * 365;
        uint256 thirtyMinutes = 60 * 30; // in seconds
        IKairos kairos = IKairos(0xCA3624F4B6872662014588C5D7833e959eefa5Eb);
        BetaSettersFacet betaSetters = BetaSettersFacet(0xC82460fe25434dCA26801C30a27DC9b2E2cdF62B);

        IDiamond.FacetCut[] memory facetCuts = new IDiamond.FacetCut[](1);

        facetCuts[0] = IDiamond.FacetCut({
            facetAddress: address(betaSetters),
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: betaSettersFS()
        });

        vm.startBroadcast(deployerKey);
        kairos.diamondCut(facetCuts, address(0), emptyBytes);
        BetaSettersFacet(address(kairos)).setAprAndAuctionDuration({
            newTrancheZero: ONE.div(10).mul(4).div(oneBetaYear),
            newAuctionDuration: thirtyMinutes
        });
    }
}
