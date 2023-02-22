// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";

import {Money} from "../../../src/mock/Money.sol";
import {NFT} from "../../../src/mock/NFT.sol";

contract Deploy is Script {
    function run() public {
        vm.startBroadcast(vm.envUint("TEST_PKEY"));
        new NFT("Test NFT", "TNFT");
        new Money();
    }
}
