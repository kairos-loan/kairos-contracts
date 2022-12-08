// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";

import "../src/mock/NFT.sol";
import "../src/mock/Money.sol";

contract Deploy is Script {
    function run() public {
        vm.startBroadcast(vm.envUint("TEST_PKEY"));
        new NFT("Test NFT", "TNFT");
        new Money();
    }
}
