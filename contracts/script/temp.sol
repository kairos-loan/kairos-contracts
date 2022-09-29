// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";

import "../DataStructure/Global.sol";
import "contracts/interface/IKairos.sol";

/// @dev use for quick tests

contract ContractScript is Script {
    function run() public {
        uint256 KEY = 0xA11CE;
        bytes32 digest = 0x68510e5f9f8e078fa1ee17dfcbfdf780f1ead4d1f97b48e031d30d6d992df6b3;
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(KEY, digest);
        bytes memory signature = bytes.concat(r, s, bytes1(v));
        console.log(vm.addr(KEY));
    }
}