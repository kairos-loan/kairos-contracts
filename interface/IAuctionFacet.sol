// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../src/DataStructure/Global.sol";

interface IAuctionFacet {
    function buy(BuyArgs[] memory args) external;

    function price(uint256 loanId) external view returns (uint256);
}
