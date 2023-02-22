// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";

import {IKairos} from "../../../src/interface/IKairos.sol";
import {TestCurrency} from "../../../src/mock/TestCurrency.sol";

contract MintAndApproveKWethToKairos_22_02_23_18 is Script {
    function run() public {
        uint256 deployerKey = vm.envUint("DEPLOYER_KEY");
        TestCurrency betaFakeWeth = TestCurrency(0x3F39773D17812c4B0C9A2c5fA9205b9c290dA91E);
        IKairos kairos = IKairos(0xDE75133b77762b056903584a509D722aC7aE352e);

        vm.startBroadcast(deployerKey);
        betaFakeWeth.mint(100_000_000 ether);
        betaFakeWeth.approve(address(kairos), 100_000_000 ether);
    }
}
