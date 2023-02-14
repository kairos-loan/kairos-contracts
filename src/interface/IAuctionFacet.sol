// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {BuyArg} from "../DataStructure/Objects.sol";

interface IAuctionFacet {
    function buy(BuyArg[] memory args) external;

    function price(uint256 loanId) external view returns (uint256);
}
