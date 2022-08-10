// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

/// @notice handles signature verification
abstract contract Signature is EIP712 {
    /* solhint-disable-next-line no-empty-blocks */
    constructor() EIP712("NFTACLP", "0.1") {}
}