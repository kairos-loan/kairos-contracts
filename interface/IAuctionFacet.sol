// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {BuyArgs} from "../src/DataStructure/Objects.sol";

interface IAuctionFacet {
    function buy(BuyArgs[] memory args) external;

    function price(uint256 loanId) external view returns (uint256);
}
