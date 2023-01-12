// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";

import "../src/mock/ParamTypesGenerator.sol";
import "../test/Commons/External.sol";

contract Deploy is Script, External {
    function run() public {
        console.logBytes(abi.encode(getOfferArgs()));
    }
}
