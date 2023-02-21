// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestCurrency is ERC20 {
    /* solhint-disable-next-line no-empty-blocks */
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(uint256 amount) external {
        _mint(msg.sender, amount);
    }

    function mint(uint256 amount, address to) external {
        _mint(to, amount);
    }
}
