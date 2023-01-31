// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {Script} from "forge-std/Script.sol";

import {TestCurrency} from "../../src/mock/TestCurrency.sol";

contract MintKWEthToSupplier is Script {
    function run() public {
        uint256 deployerKey = vm.envUint("DEPLOYER_KEY");
        TestCurrency betaFakeWeth = TestCurrency(0x659e527F2A0de2ABc954351a736Ec4157d90A379);

        vm.startBroadcast(deployerKey);
        betaFakeWeth.mint(100_000_000 ether);
    }
}
