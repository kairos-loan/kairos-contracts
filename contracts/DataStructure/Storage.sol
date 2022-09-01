// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "./Objects.sol";

// todo : docs 

/// @notice General protocol
/// @member rateOfTranche interest rate of tranche of provided id, in multiplier per second
struct Protocol {
    mapping(uint256 => Ray) rateOfTranche;
    uint256 nbOfLoans;
    mapping(uint256 => Loan) loan;
    mapping(address => uint256) supplierNonce;
}

/// @notice Issued Loan (corresponding to one collateral)
/// @member assetLent currency lent
/// @member lent total amount lent
/// @member endDate timestamp after which sale starts & repay is impossible
/// @member tranche identifies the interest rate tranche
/// @member borrower borrowing account
/// @member collateral NFT contract of collateral
/// @member tokenId identifies the collateral in his collection
/// @member supplyPositionIds identifier of the supply position tokens
struct Loan {
    IERC20 assetLent;
    uint256 lent;
    uint256 endDate;
    uint256 tranche;
    address borrower;
    IERC721 collateral;
    uint256 tokenId;
    uint256[] supplyPositionIds;
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
struct Provision {
    uint256 amount;
    Ray share;
}