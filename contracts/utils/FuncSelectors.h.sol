// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "diamond/interfaces/IDiamondLoupe.sol";
import "diamond/interfaces/IDiamondCut.sol";
import "diamond/facets/OwnershipFacet.sol";
import "diamond/interfaces/IERC165.sol";

import "../SupplyPositionFacet.sol";
import "../interface/IBorrowFacet.sol";
import "../interface/IProtocolFacet.sol";
import "../interface/IRepayFacet.sol";
import "../interface/IAuctionFacet.sol";
import "../interface/IClaimFacet.sol";

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

function cutFS() pure returns(bytes4[] memory) {
    bytes4[] memory functionSelectors = new bytes4[](1);
    
    functionSelectors[0] = IDiamondCut.diamondCut.selector;

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
    bytes4[] memory functionSelectors = new bytes4[](13);

    functionSelectors[0] = IERC721.balanceOf.selector;
    functionSelectors[1] = IERC721.ownerOf.selector;
    functionSelectors[2] = DiamondERC721.name.selector;
    functionSelectors[3] = DiamondERC721.symbol.selector;
    functionSelectors[4] = IERC721.approve.selector;
    functionSelectors[5] = IERC721.getApproved.selector;
    functionSelectors[6] = IERC721.setApprovalForAll.selector;
    functionSelectors[7] = IERC721.isApprovedForAll.selector;
    functionSelectors[8] = IERC721.transferFrom.selector;
    functionSelectors[9] = getSelector("safeTransferFrom(address,address,uint256)");
    functionSelectors[10] = getSelector("safeTransferFrom(address,address,uint256,bytes)");
    functionSelectors[11] = SupplyPositionFacet.position.selector;
    functionSelectors[12] = SupplyPositionFacet.totalSupply.selector;

    return functionSelectors;
}

/// @notice protocol facet function selectors 
function protoFS() pure returns(bytes4[] memory) {
    bytes4[] memory functionSelectors = new bytes4[](5);

    functionSelectors[0] = IProtocolFacet.updateOffers.selector;
    functionSelectors[1] = IProtocolFacet.getRateOfTranche.selector;
    functionSelectors[2] = IProtocolFacet.getParameters.selector;
    functionSelectors[3] = IProtocolFacet.getLoan.selector;
    functionSelectors[4] = IProtocolFacet.getSupplierNonce.selector;

    return functionSelectors;
}

function repayFS() pure returns(bytes4[] memory) {
    bytes4[] memory functionSelectors = new bytes4[](1);

    functionSelectors[0] = IRepayFacet.repay.selector;

    return functionSelectors;
}

function auctionFS() pure returns(bytes4[] memory) {
    bytes4[] memory functionSelectors = new bytes4[](1);

    functionSelectors[0] = IAuctionFacet.buy.selector;

    return functionSelectors;
}

function claimFS() pure returns(bytes4[] memory) {
    bytes4[] memory functionSelectors = new bytes4[](2);

    functionSelectors[0] = IClaimFacet.claim.selector;
    functionSelectors[1] = IClaimFacet.claimAsBorrower.selector;

    return functionSelectors;
}

function getSelector(string memory _func) pure returns (bytes4) {
    return bytes4(keccak256(bytes(_func)));
}