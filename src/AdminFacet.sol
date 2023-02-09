// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {IOwnershipFacet} from "./interface/IOwnershipFacet.sol";
import {Ray} from "./DataStructure/Objects.sol";
import {SupplyPosition, Protocol} from "./DataStructure/Storage.sol";
import {protocolStorage} from "./DataStructure/Global.sol";
import {CallerIsNotOwner} from "./DataStructure/Errors.sol";

/// @notice admin-only setters for global protocol parameters
contract AdminFacet {
    /// @notice duration of future auctions has been updated
    /// @param newAuctionDuration duration of liquidation for new loans
    event NewAuctionDuration(uint256 indexed newAuctionDuration);

    /// @notice initial price factor of future auctions has been updated
    /// @param newAuctionPriceFactor factor of loan to value setting initial price of auctions
    event NewAuctionPriceFactor(Ray indexed newAuctionPriceFactor);

    /// @notice a new interest rate tranche has been created
    /// @param tranche the interest rate of the new tranche, in multiplier per second
    /// @param newTrancheId identifier of the new tranche
    event NewTranche(Ray indexed tranche, uint256 indexed newTrancheId);

    modifier onlyOwner() {
        address admin = IOwnershipFacet(address(this)).owner();
        if (msg.sender != admin) {
            revert CallerIsNotOwner(admin);
        }
        _;
    }

    function setAuctionDuration(uint256 newAuctionDuration) external onlyOwner {
        protocolStorage().auction.duration = newAuctionDuration;
        emit NewAuctionDuration(newAuctionDuration);
    }

    function setAuctionPriceFactor(Ray newAuctionPriceFactor) external onlyOwner {
        protocolStorage().auction.priceFactor = newAuctionPriceFactor;
        emit NewAuctionPriceFactor(newAuctionPriceFactor);
    }

    function createTranche(Ray newTranche) external onlyOwner returns (uint256 newTrancheId) {
        Protocol storage proto = protocolStorage();

        newTrancheId = ++proto.nbOfTranches;
        proto.tranche[newTrancheId] = newTranche;
    }
}
