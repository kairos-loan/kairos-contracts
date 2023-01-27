// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {Script} from "forge-std/Script.sol";

//                          format is dd_mm_yy_hh
contract UpdateAuctionBorrowAndKairos_27_01_23_14 is Script {
    function run() public {
        uint256 deployerKey = vm.envUint("DEPLOYER_KEY");
        vm.startBroadcast(deployerKey);
    }
}
