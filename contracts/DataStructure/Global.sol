// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "./Errors.sol";

bytes32 constant ROOT_TYPEHASH = keccak256("Root(bytes32 root)");

bytes32 constant PROTOCOL_SP = keccak256("eth.nftaclp.protocol");
bytes32 constant SUPPLY_SP = keccak256("eth.nftaclp.supply-position");
bytes32 constant SIGNATURE_SP = keccak256("eth.nftaclp.eip712.signature");

uint256 constant RAY = 1e27;
Ray constant ONE = Ray.wrap(RAY);

/* solhint-disable func-visibility */

function protocolStorage() pure returns (Protocol storage protocol) {
    bytes32 position = PROTOCOL_SP;
    /* solhint-disable-next-line no-inline-assembly */
    assembly {
        protocol.slot := position
    }
}

function supplyPositionStorage() pure returns (SupplyPosition storage sp) {
    bytes32 position = SUPPLY_SP;
    /* solhint-disable-next-line no-inline-assembly */
    assembly {
        sp.slot := position
    }
}

function signatureStorage() pure returns (EIP712Signature storage sig) {
    bytes32 position = SIGNATURE_SP;
    /* solhint-disable-next-line no-inline-assembly */
    assembly {
        sig.slot := position
    }
}