// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../../src/AuctionFacet.sol";
import "../../src/BorrowFacet.sol";
import "../../src/ClaimFacet.sol";
import "../../src/ProtocolFacet.sol";
import "../../src/RepayFacet.sol";
import "../../src/SupplyPositionFacet.sol";

/// @notice immutable version of kairos including all facets for usage in internal tests
contract BigKairos is AuctionFacet, BorrowFacet, ClaimFacet, ProtocolFacet, RepayFacet, SupplyPositionFacet {
    /* solhint-disable no-empty-blocks */
    function emitTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(DiamondERC721, SafeMint) {}

    function emitApproval(
        address owner,
        address approved,
        uint256 tokenId
    ) internal override(DiamondERC721, SafeMint) {}

    function emitApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal override(DiamondERC721, SafeMint) {}
}
