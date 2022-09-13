// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "./Errors.sol";

bytes32 constant ROOT_TYPEHASH = keccak256("Root(bytes32 root)");

bytes32 constant PROTOCOL_SP = keccak256("eth.nftaclp.protocol");
bytes32 constant SUPPLY_SP = keccak256("eth.nftaclp.supply-position");

uint256 constant RAY = 1e27;
Ray constant ONE = Ray.wrap(RAY);
Ray constant ZERO = Ray.wrap(0);

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
