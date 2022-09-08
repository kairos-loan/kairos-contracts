// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "diamond/interfaces/IDiamondLoupe.sol";
import "diamond/facets/OwnershipFacet.sol";
import "diamond/interfaces/IERC165.sol";

import "../SupplyPositionFacet.sol";
import "../interface/IBorrowFacet.sol";
import "../interface/IProtocolFacet.sol";
import "../interface/IRepayFacet.sol";

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
    bytes4[] memory functionSelectors = new bytes4[](3);

    functionSelectors[0] = IBorrowFacet.onERC721Received.selector;
    functionSelectors[1] = IBorrowFacet.rootDigest.selector;
    functionSelectors[2] = IBorrowFacet.borrow.selector;

    return functionSelectors;
}

function supplyPositionFS() pure returns(bytes4[] memory) {
    bytes4[] memory functionSelectors = new bytes4[](15);

    functionSelectors[0] = SupplyPositionFacet.safeMint.selector;
    functionSelectors[1] = SupplyPositionFacet.burn.selector;
    functionSelectors[2] = IERC721.balanceOf.selector;
    functionSelectors[3] = IERC721.ownerOf.selector;
    functionSelectors[4] = DiamondERC721.name.selector;
    functionSelectors[5] = DiamondERC721.symbol.selector;
    functionSelectors[6] = IERC721.approve.selector;
    functionSelectors[7] = IERC721.getApproved.selector;
    functionSelectors[8] = IERC721.setApprovalForAll.selector;
    functionSelectors[9] = IERC721.isApprovedForAll.selector;
    functionSelectors[10] = IERC721.transferFrom.selector;
    functionSelectors[11] = getSelector("safeTransferFrom(address,address,uint256)");
    functionSelectors[12] = getSelector("safeTransferFrom(address,address,uint256,bytes)");
    functionSelectors[13] = SupplyPositionFacet.position.selector;
    functionSelectors[14] = SupplyPositionFacet.totalSupply.selector;

    return functionSelectors;
}

/// @notice protocol facet function selectors 
function protoFS() pure returns(bytes4[] memory) {
    bytes4[] memory functionSelectors = new bytes4[](5);

    functionSelectors[0] = IProtocolFacet.updateOffers.selector;
    functionSelectors[1] = IProtocolFacet.getRateOfTranche.selector;
    functionSelectors[2] = IProtocolFacet.getNbOfLoans.selector;
    functionSelectors[3] = IProtocolFacet.getLoan.selector;
    functionSelectors[4] = IProtocolFacet.getSupplierNonce.selector;

    return functionSelectors;
}

function repayFS() pure returns(bytes4[] memory) {
    bytes4[] memory functionSelectors = new bytes4[](1);

    functionSelectors[0] = IRepayFacet.repay.selector;

    return functionSelectors;
}

function getSelector(string memory _func) pure returns (bytes4) {
    return bytes4(keccak256(bytes(_func)));
}