// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Money is ERC20 {
    /* solhint-disable-next-line no-empty-blocks */
    constructor() ERC20("Money", "MON") {}

    function mint(uint256 amount) public {
        _mint(msg.sender, amount);
    }
}
