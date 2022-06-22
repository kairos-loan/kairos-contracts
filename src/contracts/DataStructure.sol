// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

/// @notice Loan offer
/// @member assetToLend address of the ERC-20 to lend
/// @member loanToValue amount to lend per collateral unit
/// @member duration in seconds, time before mandatory repayment after loan start
/// @member nonce used to determine if the offer is still valid
/// @member collateralSpecType identifies logic to establish validity of an asset
/// @member collateralSpecs abi-encoded arguments for the validity checker
struct Offer {
    address assetToLend;
    uint256 loanToValue;
    uint256 duration;
    uint256 nonce;
    uint256 collateralSpecType;
    bytes collateralSpecs;
}