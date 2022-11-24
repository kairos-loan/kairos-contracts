// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "contracts/AuctionFacet.sol";
import "contracts/BorrowFacet.sol";
import "contracts/ClaimFacet.sol";
import "contracts/ProtocolFacet.sol";
import "contracts/RepayFacet.sol";
import "contracts/SupplyPositionFacet.sol";

/// @notice immutable version of kairos including all facets for usage in internal tests
/* solhint-disable-next-line no-empty-blocks */
contract BigKairos is AuctionFacet, BorrowFacet, ClaimFacet, ProtocolFacet, RepayFacet, SupplyPositionFacet {

}
