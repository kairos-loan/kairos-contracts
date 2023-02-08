// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {Offer} from "../src/DataStructure/Objects.sol";

interface ISignature {
    function offerDigest(Offer memory offer) external view returns (bytes32);
}
