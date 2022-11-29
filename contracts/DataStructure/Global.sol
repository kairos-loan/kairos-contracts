// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./Errors.sol";

bytes32 constant OFFER_TYPEHASH = keccak256(
    "Offer(address assetToLend,uint256 loanToValue,uint256 duration,uint256 expirationDate,uint256 tranche,NFToken collateral)NFToken(address implem,uint256 id)"
); // generated with ethers js

bytes32 constant PROTOCOL_SP = keccak256("eth.kairos.protocol");
bytes32 constant SUPPLY_SP = keccak256("eth.kairos.supply-position");

uint256 constant RAY = 1e27;
Ray constant ONE = Ray.wrap(RAY);
Ray constant ZERO = Ray.wrap(0);

/* solhint-disable func-visibility */

/// @dev getters of storage regions of the contract for specified usage

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
