// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "./DataStructure/Global.sol";

/// @notice handles signature verification
/// @dev diamond-friendly reimplementation of OZ's EIP712
abstract contract Signature {
    /// @dev do not include in the function selectors getters
    function initSignature(string memory name, string memory version) internal {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        signatureStorage().cachedDomainSeparator = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
    }

    function _domainSeparatorV4() internal view returns (bytes32) {
        return signatureStorage().cachedDomainSeparator;
    }

    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }
}