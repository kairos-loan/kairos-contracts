// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../DataStructure/Global.sol";

interface IAuctionFacet {
    function buy(BuyArgs[] memory args) external;
}