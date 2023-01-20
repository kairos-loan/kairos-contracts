// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {Script} from "forge-std/Script.sol";
import {IKairos} from "../interface/IKairos.sol";
import {IClaimFacet} from "../interface/IClaimFacet.sol";
import {IAuctionFacet} from "../interface/IAuctionFacet.sol";
import {IDiamond} from "diamond/contracts/interfaces/IDiamond.sol";
import {claimFS, auctionFS} from "../src/utils/FuncSelectors.h.sol";

// for goerli adding two missing facets
contract AddDeployedFacets is Script {
    function run() public {
        uint256 deployerKey = vm.envUint("DEPLOYER_KEY");
        bytes memory emptyBytes;
        IKairos kairos = IKairos(0xCA3624F4B6872662014588C5D7833e959eefa5Eb);
        IClaimFacet claim = IClaimFacet(0xf4e3e6Bb0B70e8baf3Aabe6Df4fc9dE61b728ac9);
        IAuctionFacet auction = IAuctionFacet(0x6e460F61B439F80f2e9Faa1e9B5D11E4dBC217E7);

        IDiamond.FacetCut[] memory facetCuts = new IDiamond.FacetCut[](2);

        facetCuts[0] = IDiamond.FacetCut({
            facetAddress: address(claim),
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: claimFS()
        });
        facetCuts[1] = IDiamond.FacetCut({
            facetAddress: address(auction),
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: auctionFS()
        });

        vm.startBroadcast(deployerKey);
        kairos.diamondCut(facetCuts, address(0), emptyBytes);
    }
}
