// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {ERC20TransferFailed} from "../DataStructure/Errors.sol";

library Erc20CheckedTransfer {
    function checkedTransferFrom(IERC20 currency, address from, address to, uint256 amount) internal {
        if (!currency.transferFrom(from, to, amount)) {
            revert ERC20TransferFailed(currency, from, to);
        }
    }

    function checkedTransfer(IERC20 currency, address to, uint256 amount) internal {
        if (!currency.transfer(to, amount)) {
            revert ERC20TransferFailed(currency, address(this), to);
        }
    }
}
