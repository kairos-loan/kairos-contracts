// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {AuctionFacet} from "../../src/AuctionFacet.sol";
import {BorrowFacet} from "../../src/BorrowFacet.sol";
import {ClaimFacet} from "../../src/ClaimFacet.sol";
import {DiamondERC721} from "../../src/SupplyPositionLogic/DiamondERC721.sol";
import {ProtocolFacet} from "../../src/ProtocolFacet.sol";
import {RepayFacet} from "../../src/RepayFacet.sol";
import {SafeMint} from "../../src/SupplyPositionLogic/SafeMint.sol";
import {SupplyPositionFacet} from "../../src/SupplyPositionFacet.sol";

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
