// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "kmain-contracts/AuctionFacet.sol";
import "kmain-contracts/BorrowFacet.sol";
import "kmain-contracts/ClaimFacet.sol";
import "kmain-contracts/ProtocolFacet.sol";
import "kmain-contracts/RepayFacet.sol";
import "kmain-contracts/SupplyPositionFacet.sol";

/// @notice immutable version of kairos including all facets for usage in internal tests
/* solhint-disable-next-line no-empty-blocks */
contract BigKairos is AuctionFacet, BorrowFacet, ClaimFacet, ProtocolFacet, RepayFacet, SupplyPositionFacet {

}
