// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

/// @notice handles signature verification
abstract contract Signature is EIP712 {
    /* solhint-disable-next-line no-empty-blocks */
    constructor() EIP712("Kairos protocol", "0.1") {}
}