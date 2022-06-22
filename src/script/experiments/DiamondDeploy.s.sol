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
        // vm.broadcast();

        // 1. Deploy Diamond cut facet
        DiamondCutFacet cut = new DiamondCutFacet();
        console.log(1);

        // 2. Deploy the diamond setting owner & diamond cut facet
        Diamond diamond = new Diamond(owner, address(cut));
        console.log(2);

        // 3. Deploy DiamondInit (func that will be delegatecall in future upgrades)
        DiamondInit diamondInit = new DiamondInit();
        console.log(3);

        // 4. Deploy Facets
        DiamondLoupeFacet loupe = new DiamondLoupeFacet();
        console.log(4);

        OwnershipFacet ownership = new OwnershipFacet();
        console.log(5);

        // 6. Diamond is upgarded with facets
        console.log(6);

        IDiamondCut.FacetCut[] memory facetCuts = new IDiamondCut.FacetCut[](1);
        console.log(7);

        bytes4[] memory functionSelectors = new bytes4[](5);
        console.log(8);
    
        functionSelectors[0] = loupe.facets.selector;
        functionSelectors[1] = loupe.facetFunctionSelectors.selector;
        functionSelectors[2] = loupe.facetAddresses.selector;
        functionSelectors[3] = loupe.facetAddress.selector;
        functionSelectors[4] = loupe.supportsInterface.selector;
        console.log(9);

        facetCuts[0] = IDiamondCut.FacetCut({
            facetAddress: address(loupe),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: functionSelectors
        });
        console.log(10);

        IDiamondCut(address(diamond)).diamondCut(facetCuts, address(0x0), "");
        // facetCuts[1] = ownership;
        // upgradableDiamond.diamondCut(facetCuts, address(diamondInit), abi.encodeWithSelector(diamondInit.init.selector));
    }
}