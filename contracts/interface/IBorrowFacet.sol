// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

interface IBorrowFacet {
    struct Root { bytes32 root; }

    function onERC721Received(
        address operator, 
        address from, 
        uint256 tokenId, 
        bytes memory data) external returns (bytes4);
    function rootDigest(Root memory _root) external view returns(bytes32);
}
