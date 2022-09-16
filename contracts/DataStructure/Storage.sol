// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./Objects.sol";

// todo : docs 

/// @notice General protocol
/// @member tranche interest rate of tranche of provided id, in multiplier per second
/// @member auctionDuration number of seconds after the auction start when the price hits 0 
/// @member auctionPriceFactor multiplier of the mean tvl used as start price for the auction
struct Protocol {
    uint256 auctionDuration;
    uint256 nbOfLoans;
    Ray auctionPriceFactor;
    mapping(uint256 => Ray) tranche;
    mapping(uint256 => Loan) loan;
    mapping(address => uint256) supplierNonce;
}

/// @notice Issued Loan (corresponding to one collateral)
/// @member assetLent currency lent
/// @member lent total amount lent
/// @member startDate timestamp of the borrowing transaction
/// @member shareLent between 0 and 1, the share of the collateral value lent
/// @member endDate timestamp after which sale starts & repay is impossible
/// @member interestPerSecond share of the amount lent added to the debt per second
/// @member borrower borrowing account
/// @member collateral NFT asset used as collateral
/// @member supplyPositionIndex identifier of the first supply position used in the loan
/// @member payment data on the payment, a non-0 payment.paid value means the loan lifecyle is over
/// @member nbOfPositions number of supply positions used, which ids are consecutive to the index
struct Loan {
    IERC20 assetLent;
    uint256 lent;
    Ray shareLent;
    uint256 startDate;
    uint256 endDate;
    Ray interestPerSecond;
    address borrower;
    NFToken collateral;
    uint256 supplyPositionIndex;
    Payment payment;
    uint8 nbOfPositions;
}

struct Payment {
    uint256 paid;
    bool liquidated;
    bool borrowerClaimed;
    bool borrowerBought;
}

struct SupplyPosition {
    string name;
    string symbol;
    uint256 totalSupply;
    mapping(uint256 => address) owner;
    mapping(address => uint256) balance;
    mapping(uint256 => address) tokenApproval;
    mapping(address => mapping(address => bool)) operatorApproval;
    mapping(uint256 => Provision) provision;
}

/// @notice data on a liquidity provision from a supply offer in one existing loan
/// @member amount - supplied for this provision
/// @member share - of the collateral matched by this provision
/// @member loanId identifier of the loan the liquidity went to
struct Provision {
    uint256 amount;
    Ray share;
    uint256 loanId;
}
