// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "diamond/interfaces/IDiamondLoupe.sol";
import "diamond/facets/OwnershipFacet.sol";
import "diamond/interfaces/IERC165.sol";

import "../SupplyPositionFacet.sol";
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

function supplyPositionFS() pure returns(bytes4[] memory) {
    bytes4[] memory functionSelectors = new bytes4[](13);

    functionSelectors[0] = SupplyPositionFacet.safeMint.selector;
    functionSelectors[1] = SupplyPositionFacet.burn.selector;
    functionSelectors[2] = SupplyPositionFacet.balanceOf.selector;
    functionSelectors[3] = SupplyPositionFacet.ownerOf.selector;
    functionSelectors[4] = SupplyPositionFacet.name.selector;
    functionSelectors[5] = SupplyPositionFacet.symbol.selector;
    functionSelectors[6] = SupplyPositionFacet.approve.selector;
    functionSelectors[7] = SupplyPositionFacet.getApproved.selector;
    functionSelectors[8] = SupplyPositionFacet.setApprovalForAll.selector;
    functionSelectors[9] = SupplyPositionFacet.isApprovedForAll.selector;
    functionSelectors[10] = SupplyPositionFacet.transferFrom.selector;
    functionSelectors[11] = getSelector("safeTransferFrom(address,address,uint256)");
    functionSelectors[12] = getSelector("safeTransferFrom(address,address,uint256,bytes)");

    return functionSelectors;
}

function getSelector(string memory _func) pure returns (bytes4) {
    return bytes4(keccak256(bytes(_func)));
}