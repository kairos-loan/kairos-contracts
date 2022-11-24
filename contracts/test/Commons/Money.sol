// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Money is ERC20 {
    constructor() ERC20("Money", "MON") {
        mint(100 ether);
    }

    function mint(uint256 amount) public {
        _mint(msg.sender, amount);
    }
}
