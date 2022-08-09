pragma solidity ^0.8.10;

interface IBorrow {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) external returns (bytes4);
}
