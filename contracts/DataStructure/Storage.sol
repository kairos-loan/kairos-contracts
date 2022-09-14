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
/// @member endDate timestamp after which sale starts & repay is impossible
/// @member interestPerSecond share of the amount lent added to the debt per second
/// @member borrower borrowing account
/// @member collateral NFT contract of collateral
/// @member tokenId identifies the collateral in his collection
/// @member repaid amount repaid or obtained from sale, non 0 value means the loan lifecycle is over
/// @member liquidated the asset has been sold in auction
/// @member borrowerClaimed the borrower claimed his rights on this loan (used in case of liquidation)
/// @member supplyPositionIds identifier of the supply position tokens
struct Loan {
    IERC20 assetLent;
    uint256 lent;
    Ray shareLent;
    uint256 startDate;
    uint256 endDate;
    Ray interestPerSecond;
    address borrower;
    IERC721 collateral;
    uint256 tokenId;
    uint256 repaid;
    bool liquidated;
    bool borrowerClaimed;
    uint256[] supplyPositionIds; // todo : useful ? can be replaced by startId + nbOfPos
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
