// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "./Objects.sol";

// todo : docs 

/// @notice General protocol
/// @member rateOfTranche interest rate of tranche of provided id, in multiplier per second
struct Protocol {
    mapping(uint256 => Ray) tranche;
    uint256 nbOfLoans;
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
/// @member supplyPositionIds identifier of the supply position tokens
struct Loan {
    IERC20 assetLent;
    uint256 lent;
    uint256 startDate;
    uint256 endDate;
    Ray interestPerSecond;
    address borrower;
    IERC721 collateral;
    uint256 tokenId;
    uint256 repaid;
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

/// @title data on a liquidity provision from a supply offer in one existing loan
/// @member amount - supplied for this provision
/// @member share - of the collateral matched by this provision
/// @member loanId identifier of the loan the liquidity went to
struct Provision {
    uint256 amount;
    Ray share;
    uint256 loanId;
}
