// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Diamond, DiamondArgs} from "diamond/contracts/Diamond.sol";
import {IDiamond} from "diamond/contracts/interfaces/IDiamond.sol";

import {ContractsCreator} from "../../src/ContractsCreator.sol";
import {DCHelperFacet} from "./DCHelperFacet.sol";
import {DCTarget} from "./DCTarget.sol";
import {IDCHelperFacet} from "../../src/interface/IDCHelperFacet.sol";
import {IKairos} from "../../src/interface/IKairos.sol";
import {Money} from "../../src/mock/Money.sol";
import {NFT} from "../../src/mock/NFT.sol";
import {Offer, Ray} from "../../src/DataStructure/Objects.sol";
import {RayMath} from "../../src/utils/RayMath.sol";
import {TestCommons} from "./TestCommons.sol";

contract SetUp is TestCommons, ContractsCreator {
    IKairos internal kairos;
    DCHelperFacet internal helper;
    DCTarget internal dcTarget;

    constructor() {
        createContracts();
        helper = new DCHelperFacet();
        dcTarget = new DCTarget();
    }

    function setUp() public {
        bytes memory emptyBytes;

        DiamondArgs memory args = DiamondArgs({
            owner: address(this),
            init: address(initializer),
            initCalldata: abi.encodeWithSelector(initializer.init.selector)
        });
        kairos = IKairos(address(new Diamond(getFacetCuts(), args)));
        kairos.diamondCut(testFacetCuts(), address(0), emptyBytes);
        kairos.transferOwnership(OWNER);
        nft = new NFT("Test NFT", "TNFT");
        vm.label(address(nft), "nft");
        nft2 = new NFT("Test NFT2", "TNFT2");
        vm.label(address(nft2), "nft2");
        money = new Money();
        vm.label(address(money), "money");
        money2 = new Money();
        vm.label(address(money2), "money2");
    }

    function testFacetCuts() internal view returns (IDiamond.FacetCut[] memory) {
        IDiamond.FacetCut[] memory facetCuts = new IDiamond.FacetCut[](1);

        facetCuts[0] = IDiamond.FacetCut({
            facetAddress: address(helper),
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: helperFS()
        });

        return facetCuts;
    }

    /// @dev use only in TestCommons
    function getOfferDigest(Offer memory offer) internal view override returns (bytes32) {
        return kairos.offerDigest(offer);
    }

    /// @dev use only in TestCommons
    function getTranche(uint256 trancheId) internal view override returns (Ray rate) {
        return kairos.getRateOfTranche(trancheId);
    }

    function helperFS() private pure returns (bytes4[] memory) {
        bytes4[] memory functionSelectors = new bytes4[](1);

        functionSelectors[0] = DCHelperFacet.delegateCall.selector;

        return functionSelectors;
    }
}
