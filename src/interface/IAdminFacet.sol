// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Ray} from "../DataStructure/Objects.sol";

interface IAdminFacet {
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

    function setAuctionDuration(uint256 newAuctionDuration) external;

    function setAuctionPriceFactor(Ray newAuctionPriceFactor) external;

    function createTranche(Ray newTranche) external returns (uint256 newTrancheId);
}
