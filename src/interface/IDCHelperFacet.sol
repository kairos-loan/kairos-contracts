// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

interface IDCHelperFacet {
    function delegateCall(address toCall, bytes memory data) external returns (bytes memory);
}
