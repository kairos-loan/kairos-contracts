// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {Script} from "forge-std/Script.sol";

import {IKairos} from "../../interface/IKairos.sol";
import {TestCurrency} from "../../src/mock/TestCurrency.sol";

contract ApproveKWethToKairos is Script {
    function run() public {
        uint256 deployerKey = vm.envUint("DEPLOYER_KEY");
        TestCurrency betaFakeWeth = TestCurrency(0x659e527F2A0de2ABc954351a736Ec4157d90A379);
        IKairos kairos = IKairos(0x924ee2047cC11c3E293BFE95d4664986c6fc2D90);

        vm.startBroadcast(deployerKey);
        betaFakeWeth.approve(address(kairos), 100_000_000 ether);
    }
}
