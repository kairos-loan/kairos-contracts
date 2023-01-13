// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {NFToken, Ray} from "./Objects.sol";

/// @notice type definitions of data permanently stored

/// @notice General protocol
/// @member auctionDuration number of seconds after the auction start when the price hits 0
/// @member nbOfLoans total number of loans ever issued (active and ended)
/// @member auctionPriceFactor multiplier of the mean tvl used as start price for the auction
/// @member tranche interest rate of tranche of provided id, in multiplier per second
///         I.e lent * time since loan start * tranche = interests to repay
/// @member loan - of id -
struct Protocol {
    // todo #71 add admin methods to tweak parameters
    uint256 auctionDuration;
    uint256 nbOfLoans;
    Ray auctionPriceFactor;
    mapping(uint256 => Ray) tranche;
    mapping(uint256 => Loan) loan;
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

/// @notice tracking of the payment state of a loan
/// @member paid amount sent on the tx closing the loan, non-zero value means loan's lifecycle is over
/// @member liquidated this loan has been closed at the liquidation stage, the collateral has been sold
/// @member borrowerClaimed borrower claimed his rights on this loan (either collateral or share of liquidation)
/// @member borrowerBought borrower is the one who bought the collateral during the auction
struct Payment {
    uint256 paid;
    bool liquidated;
    bool borrowerClaimed;
    bool borrowerBought;
}

/// @notice storage for the ERC721 compliant supply position facets. Related NFTs represent supplier positions
/// @member name - of the NFT collection
/// @member symbol - of the NFT collection
/// @member totalSupply number of supply position ever issued - not decreased on burn
/// @member owner - of nft of id -
/// @member balance number of positions owned by -
/// @member tokenApproval address approved to transfer position of id - on behalf of its owner
/// @member operatorApproval address is approved to transfer all positions of - on his behalf
/// @member provision supply position metadata
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
