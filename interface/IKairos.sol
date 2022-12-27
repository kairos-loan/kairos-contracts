// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "diamond/contracts/interfaces/IDiamondLoupe.sol";
import "diamond/contracts/interfaces/IDiamondCut.sol";

import "./IAuctionFacet.sol";
import "./IBorrowFacet.sol";
import "./IClaimFacet.sol";
import "./IOwnershipFacet.sol";
import "./IProtocolFacet.sol";
import "./IRepayFacet.sol";
import "./ISupplyPositionFacet.sol";

/* solhint-disable-next-line no-empty-blocks */
interface IKairos is
    IDiamondLoupe,
    IDiamondCut,
    IAuctionFacet,
    IBorrowFacet,
    IClaimFacet,
    IOwnershipFacet,
    IProtocolFacet,
    IRepayFacet,
    ISupplyPositionFacet
{

}
