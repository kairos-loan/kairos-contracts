// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {IOwnershipFacet} from "../interface/IOwnershipFacet.sol";
import {Ray} from "./DataStructure/Objects.sol";
import {SupplyPosition, Protocol} from "./DataStructure/Storage.sol";
import {protocolStorage} from "./DataStructure/Global.sol";

/// @notice exposes setters for the beta
contract BetaSettersFacet {
    modifier onlyOwner() {
        require(msg.sender == IOwnershipFacet(address(this)).owner(), "caller is not owner");
        _;
    }

    function setAprAndAuctionDuration(Ray newTrancheZero, uint256 newAuctionDuration) external onlyOwner {
        Protocol storage proto = protocolStorage();

        proto.tranche[0] = newTrancheZero;
        proto.auctionDuration = newAuctionDuration;
    }
}
