// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

// Derived from Nick Mudge's DiamondInit from the reference diamond implementation

import { LibDiamond } from "diamond/libraries/LibDiamond.sol";
import { IDiamondLoupe } from "diamond/interfaces/IDiamondLoupe.sol";
import { IDiamondCut } from "diamond/interfaces/IDiamondCut.sol";
import { IERC173 } from "diamond/interfaces/IERC173.sol";
import { IERC165 } from "diamond/interfaces/IERC165.sol";

contract Initializer {    
    function init() external {
        // adding ERC165 data
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;
    }
}