// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {Script} from "forge-std/Script.sol";
import {Diamond, DiamondArgs} from "diamond/contracts/Diamond.sol";

import {ContractsCreator} from "../src/ContractsCreator.sol";

contract Deploy is Script, ContractsCreator {
    function run() public {
        uint256 privateKey = vm.envUint("TEST_PKEY");

        vm.startBroadcast(privateKey);
        createContracts();
        DiamondArgs memory args = DiamondArgs({
            owner: vm.addr(privateKey),
            init: address(initializer),
            initCalldata: abi.encodeWithSelector(initializer.init.selector)
        });
        new Diamond(getFacetCuts(), args);
    }
}
