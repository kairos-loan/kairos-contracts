// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";

import "../DataStructure/Global.sol";

/// @dev use for quick tests

contract ContractScript is Script {
    function run() public {
        console.logBytes(abi.encode(NFToken({
            implem: IERC721(0x8a90CAb2b38dba80c64b7734e58Ee1dB38B8992e),
            id: 12
        })));
    }
}