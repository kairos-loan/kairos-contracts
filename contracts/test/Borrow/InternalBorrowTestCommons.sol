// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../TestCommons.sol";
import "../../BorrowLogic/BorrowCheckers.sol";

contract InternalBorrowTestCommons is BorrowCheckers, TestCommons {
    IERC20 internal constant MOCK_TOKEN = IERC20(address(bytes20(keccak256("mock token"))));

    constructor() {
        bytes memory randoCode = hex"01";
        vm.etch(address(MOCK_TOKEN), randoCode); // for mock calls to work, code needs to be not empty
    }

    function getSignatureInternal(Root memory root) internal returns (bytes memory signature) {
        bytes32 digest = rootDigest(root);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(KEY, digest);
        signature = bytes.concat(r, s, bytes1(v));
    }
}
