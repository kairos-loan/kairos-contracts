// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {TestCurrency} from "./TestCurrency.sol";

contract Money is TestCurrency {
    /* solhint-disable-next-line no-empty-blocks */
    constructor() TestCurrency("Money", "MON") {}
}
