// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "diamond/interfaces/IDiamondLoupe.sol";

import "./IAuctionFacet.sol";
import "./IBorrowFacet.sol";
import "./IClaimFacet.sol";
import "./IOwnershipFacet.sol";
import "./IProtocolFacet.sol";
import "./IRepayFacet.sol";
import "./ISupplyPositionFacet.sol";
import "diamond/interfaces/IDiamondCut.sol";

/* solhint-disable-next-line no-empty-blocks */
interface IKairos is 
    IDiamondLoupe,
    IAuctionFacet,
    IBorrowFacet,
    IClaimFacet,
    IOwnershipFacet,
    IProtocolFacet,
    IRepayFacet,
    ISupplyPositionFacet,
    IDiamondCut {}