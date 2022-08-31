// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "../BorrowLogic/BorrowCheckers.sol";

contract TestCommons is Test {
    uint256 internal constant KEY = 0xA11CE;
    address internal immutable signer;

    constructor() {
        signer = vm.addr(KEY);
    }
}