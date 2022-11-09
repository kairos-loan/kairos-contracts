// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../DataStructure/Global.sol";

interface IRepayFacet {
    function repay(uint256[] memory loanIds) external;
}
