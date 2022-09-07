// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

error DelegateCallFailed();

contract DCHelperFacet {
    function delegateCall(address toCall, bytes memory data) external returns (bytes memory) {
        /* solhint-disable-next-line avoid-low-level-calls */
        (bool success, bytes memory ret) = toCall.delegatecall(data);
        if (!success) { revert DelegateCallFailed(); }
        return ret;
    }
}