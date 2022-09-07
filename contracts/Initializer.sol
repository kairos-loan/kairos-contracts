// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

// Derived from Nick Mudge's DiamondInit from the reference diamond implementation

import { LibDiamond } from "diamond/libraries/LibDiamond.sol";
import { IDiamondLoupe } from "diamond/interfaces/IDiamondLoupe.sol";
import { IDiamondCut } from "diamond/interfaces/IDiamondCut.sol";
import { IERC173 } from "diamond/interfaces/IERC173.sol";
import { IERC165 } from "diamond/interfaces/IERC165.sol";

import "./DataStructure/Global.sol";
import "./utils/RayMath.sol";

contract Initializer {
    using RayMath for Ray;

    function init() external {
        // adding ERC165 data
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;

        // initializing tranches
        protocolStorage().tranche[0] = ONE.div(10).mul(4).div(365 days); // 40% APR

        // initializing supply position nft collection
        SupplyPosition storage sp = supplyPositionStorage();
        sp.name = "Kairos Supply Position";
        sp.symbol = "KSP";
        ds.supportedInterfaces[type(IERC721).interfaceId] = true;
        // todo : add erc721 metadata support
    }
}