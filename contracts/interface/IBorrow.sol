pragma solidity ^0.8.10;

interface IBorrow {
    struct Test { uint256 a; }

    function getDigest(Test memory _test) view external returns (bytes32);
    function hereToTest(Test memory _test, bytes memory signature) view external returns (address);
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) external returns (bytes4);
}
