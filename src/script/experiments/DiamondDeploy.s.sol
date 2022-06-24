// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "forge-std/Script.sol";

import "src/contracts/experiments/diamond/facets/DiamondCutFacet.sol";
import "src/script/experiments/DiamondDeploy.s.sol";
import "src/contracts/experiments/diamond/upgradeInitializers/DiamondInit.sol";
import "src/contracts/experiments/diamond/facets/DiamondLoupeFacet.sol";
import "src/contracts/experiments/diamond/facets/OwnershipFacet.sol";
import "src/contracts/experiments/diamond/Diamond.sol";
import "src/contracts/experiments/diamond/interfaces/IDiamondCut.sol";

// inspired by the deploy process of https://github.com/mudgen/diamond-1-hardhat

/// @notice Deploys Polypus
contract DiamondDeploy is Script {
    address private owner;

    constructor() {
        owner = address(this);
    }

    function run() public {
        // 1. Deploy Diamond cut facet
        DiamondCutFacet cut = new DiamondCutFacet();

        // 2. Deploy the diamond setting owner & diamond cut facet
        Diamond diamond = new Diamond(owner, address(cut));

        // 3. Deploy DiamondInit (func that will be delegatecall in future upgrades)
        DiamondInit diamondInit = new DiamondInit();

        // 4. Deploy Facets
        DiamondLoupeFacet loupe = new DiamondLoupeFacet();
        OwnershipFacet ownership = new OwnershipFacet();

        // 6. Diamond is upgarded with facets

        IDiamondCut.FacetCut[] memory facetCuts = new IDiamondCut.FacetCut[](1);

        bytes4[] memory functionSelectors = new bytes4[](5);
    
        functionSelectors[0] = loupe.facets.selector;
        functionSelectors[1] = loupe.facetFunctionSelectors.selector;
        functionSelectors[2] = loupe.facetAddresses.selector;
        functionSelectors[3] = loupe.facetAddress.selector;
        functionSelectors[4] = loupe.supportsInterface.selector;

        facetCuts[0] = IDiamondCut.FacetCut({
            facetAddress: address(loupe),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: functionSelectors
        });

        IDiamondCut(address(diamond)).diamondCut(facetCuts, address(diamondInit), abi.encodeWithSelector(diamondInit.init.selector));
    }
}