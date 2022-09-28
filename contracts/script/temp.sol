// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";

import "../DataStructure/Global.sol";
import "contracts/interface/Ikairos.sol";

/// @dev use for quick tests

contract ContractScript is Script {
    function run() public {
        IKairos(0xBEe6FFc1E8627F51CcDF0b4399a1e1abc5165f15).rootDigest(
            Root({root:0xb83980c5f9ef4ebbcb02e750e44dd4efed90da6a90ad1902116de9f141fb9d79}));
    }
}