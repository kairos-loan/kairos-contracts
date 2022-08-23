// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "diamond/interfaces/IDiamondLoupe.sol";
import "diamond/facets/OwnershipFacet.sol";
import "diamond/interfaces/IERC165.sol";

import "../interface/IBorrowFacet.sol";

/* solhint-disable func-visibility */

/// @notice This file is for function selectors getters of facets
/// @dev create a new function for each new facet and update them
///     according to their interface

function loupeFS() pure returns(bytes4[] memory) {
    bytes4[] memory functionSelectors = new bytes4[](5);
    
    functionSelectors[0] = IDiamondLoupe.facets.selector;
    functionSelectors[1] = IDiamondLoupe.facetFunctionSelectors.selector;
    functionSelectors[2] = IDiamondLoupe.facetAddresses.selector;
    functionSelectors[3] = IDiamondLoupe.facetAddress.selector;
    functionSelectors[4] = IERC165.supportsInterface.selector;

    return functionSelectors;
}

function ownershipFS() pure returns(bytes4[] memory) {
    bytes4[] memory functionSelectors = new bytes4[](2);
    
    functionSelectors[0] = OwnershipFacet.transferOwnership.selector;
    functionSelectors[1] = OwnershipFacet.owner.selector;

    return functionSelectors;
}

function borrowFS() pure returns(bytes4[] memory) {
    bytes4[] memory functionSelectors = new bytes4[](2);

    functionSelectors[0] = IBorrowFacet.onERC721Received.selector;
    functionSelectors[1] = IBorrowFacet.rootDigest.selector;

    return functionSelectors;
}