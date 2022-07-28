// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "diamond/facets/DiamondLoupeFacet.sol";
import "diamond/facets/OwnershipFacet.sol";

/* solhint-disable func-visibility */

/// @notice This file is for function selectors getters of facets
/// @dev create a new function for each new facet and update them
///     according to their interface

function loupeFunctionSelectors() pure returns(bytes4[] memory) {
    bytes4[] memory functionSelectors = new bytes4[](5);
    
    functionSelectors[0] = DiamondLoupeFacet.facets.selector;
    functionSelectors[1] = DiamondLoupeFacet.facetFunctionSelectors.selector;
    functionSelectors[2] = DiamondLoupeFacet.facetAddresses.selector;
    functionSelectors[3] = DiamondLoupeFacet.facetAddress.selector;
    functionSelectors[4] = DiamondLoupeFacet.supportsInterface.selector;

    return functionSelectors;
}

function ownershipFunctionSelectors() pure returns(bytes4[] memory) {
    bytes4[] memory functionSelectors = new bytes4[](2);
    
    functionSelectors[0] = OwnershipFacet.transferOwnership.selector;
    functionSelectors[1] = OwnershipFacet.owner.selector;

    return functionSelectors;
}