// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {IOwnershipFacet} from "./interface/IOwnershipFacet.sol";
import {IAdminFacet} from "./interface/IAdminFacet.sol";

import {Ray} from "./DataStructure/Objects.sol";
import {SupplyPosition, Protocol} from "./DataStructure/Storage.sol";
import {protocolStorage} from "./DataStructure/Global.sol";
import {CallerIsNotOwner} from "./DataStructure/Errors.sol";

/// @notice admin-only setters for global protocol parameters
contract AdminFacet is IAdminFacet {
    /// @notice restrict a method access to the protocol owner only
    modifier onlyOwner() {
        address admin = IOwnershipFacet(address(this)).owner();
        if (msg.sender != admin) {
            revert CallerIsNotOwner(admin);
        }
        _;
    }

    /// @notice sets the time it takes to auction prices to fall to 0 for future loans
    /// @param newAuctionDuration number of seconds of the duration
    function setAuctionDuration(uint256 newAuctionDuration) external onlyOwner {
        protocolStorage().auction.duration = newAuctionDuration;
        emit NewAuctionDuration(newAuctionDuration);
    }

    /// @notice sets the factor applied to the loan to value setting initial price of auction for future loans
    /// @param newAuctionPriceFactor the new factor multiplied to the loan to value
    function setAuctionPriceFactor(Ray newAuctionPriceFactor) external onlyOwner {
        protocolStorage().auction.priceFactor = newAuctionPriceFactor;
        emit NewAuctionPriceFactor(newAuctionPriceFactor);
    }

    /// @notice creates a new tranche at a new identifier for lenders to provide offers for
    /// @param newTranche the interest rate of the new tranche
    function createTranche(Ray newTranche) external onlyOwner returns (uint256 newTrancheId) {
        Protocol storage proto = protocolStorage();

        newTrancheId = proto.nbOfTranches++;
        proto.tranche[newTrancheId] = newTranche;
    }
}
