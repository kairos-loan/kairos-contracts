// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";


/// @title Signature Checker
contract SigCheck is EIP712 {
    struct Lol {
        uint256 lol;
    }

    bytes32 internal constant HASH_STRUCT = keccak256("Lol(uint256 lol)");
    
    constructor() EIP712("Polypus", "1"){}

    function hello(bytes memory signature) public view returns(address) {
        bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(HASH_STRUCT, 1)));
        return ECDSA.recover(digest, signature);
    }
}
