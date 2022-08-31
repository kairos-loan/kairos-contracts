// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "../BorrowLogic/BorrowCheckers.sol";
import "./TestCommons.sol";

contract BorrowCheckersTest is TestCommons {

    function setUp() public {
        Protocol storage proto = protocolStorage();
        proto.supplierNonce[signer] = 3;
    }

    function testMerkleTree() public {
        
    }
}