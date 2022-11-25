// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../../AuctionFacet.sol";
import "../../BorrowFacet.sol";
import "../../ClaimFacet.sol";
import "../../ProtocolFacet.sol";
import "../../RepayFacet.sol";
import "../../SupplyPositionFacet.sol";

/// @notice immutable version of kairos including all facets for usage in internal tests
/* solhint-disable-next-line no-empty-blocks */
contract BigKairos is AuctionFacet, BorrowFacet, ClaimFacet, ProtocolFacet, RepayFacet, SupplyPositionFacet {

}
