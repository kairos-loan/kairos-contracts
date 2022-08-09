// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "forge-std/Test.sol";

import "diamond/Diamond.sol";
import "diamond/facets/OwnershipFacet.sol";
import "diamond/facets/DiamondCutFacet.sol";
import "diamond/interfaces/IDiamondCut.sol";
import "diamond/facets/DiamondLoupeFacet.sol";
import "diamond/upgradeInitializers/DiamondInit.sol";

import "../utils/FuncSelectors.h.sol";

contract SetUp is Test {
    Diamond private diamond;
    DiamondInit private diamondInit;
    OwnershipFacet private ownership;

    function setUp() public {
        // 1. Deploy Diamond cut facet
        DiamondCutFacet cut = new DiamondCutFacet();

        // 2. Deploy the diamond setting owner & diamond cut facet
        diamond = new Diamond(address(this), address(cut));

        // 3. Deploy DiamondInit (func that will be delegatecall in future upgrades)
        diamondInit = new DiamondInit();

        // 4. Deploy Facets
        DiamondLoupeFacet loupe = new DiamondLoupeFacet();
        ownership = new OwnershipFacet();

        // 6. Diamond is upgarded with facets
        IDiamondCut.FacetCut[] memory facetCuts = new IDiamondCut.FacetCut[](2);

        facetCuts[0] = IDiamondCut.FacetCut({
            facetAddress: address(loupe),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: loupeFS()
        });

        facetCuts[1] = IDiamondCut.FacetCut({
            facetAddress: address(ownership),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: ownershipFS()
        });

        IDiamondCut(address(diamond)).diamondCut(
            facetCuts, address(diamondInit), abi.encodeWithSelector(diamondInit.init.selector));
    }
}