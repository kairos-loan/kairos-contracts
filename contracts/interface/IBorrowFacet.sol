// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "../DataStructure/Global.sol";

interface IBorrowFacet {
    function onERC721Received(
        address operator, 
        address from, 
        uint256 tokenId, 
        bytes memory data) external returns (bytes4);
    function borrow(BorrowArgs[] calldata args) external;
    function rootDigest(Root memory _root) external view returns(bytes32);
}
