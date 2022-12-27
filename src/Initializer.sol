// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

// Derived from Nick Mudge's DiamondInit from the reference diamond implementation

import {LibDiamond} from "diamond/contracts/libraries/LibDiamond.sol";
import {IDiamondLoupe} from "diamond/contracts/interfaces/IDiamondLoupe.sol";
import {IDiamondCut} from "diamond/contracts/interfaces/IDiamondCut.sol";
import {IERC173} from "diamond/contracts/interfaces/IERC173.sol";
import {IERC165} from "diamond/contracts/interfaces/IERC165.sol";

import "./DataStructure/Global.sol";
import "./utils/RayMath.sol";

/// @notice initilizes the kairos protocol
contract Initializer {
    using RayMath for Ray;

    /// @notice initilizes the kairos protocol
    /// @dev specify this method in diamond constructor
    function init() external {
        // adding ERC165 data
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;

        // initializing protocol
        Protocol storage proto = protocolStorage();
        proto.tranche[0] = ONE.div(10).mul(4).div(365 days); // 40% APR
        proto.auctionPriceFactor = ONE.mul(3);
        proto.auctionDuration = 3 days;

        // initializing supply position nft collection
        SupplyPosition storage sp = supplyPositionStorage();
        sp.name = "Kairos Supply Position";
        sp.symbol = "KSP";
        ds.supportedInterfaces[type(IERC721).interfaceId] = true;
        // todo : add erc721 metadata support
    }
}
