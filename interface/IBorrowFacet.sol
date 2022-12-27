// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../src/DataStructure/Global.sol";

interface IBorrowFacet {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) external returns (bytes4);

    function borrow(BorrowArgs[] calldata args) external;

    function offerDigest(Offer memory _offer) external view returns (bytes32);
}
