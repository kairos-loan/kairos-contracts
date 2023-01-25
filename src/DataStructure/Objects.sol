// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/// @notice file for type definitions not used in storage

/// @notice 27-decimals fixed point unsigned number
type Ray is uint256;

// todo #29 fix singular/plural forms of args

/// @notice Arguments to buy the collateral of one loan
/// @param loanId loan identifier
/// @param to address that will receive the collateral
/// @param positionIds eventual supply positions to burn to reduce totally or partially the sale price
struct BuyArgs {
    uint256 loanId;
    address to;
    uint256[] positionIds;
}

/// @notice Arguments to borrow from one collateral
/// @param nft asset to use as collateral
/// @param args arguments for the borrow parameters of the offers to use with the collateral
struct BorrowArgs {
    NFToken nft;
    OfferArgs[] args;
}

/// @notice Arguments for the borrow parameters of an offer
/// @dev '-' means n^th
/// @param signature - of the offer
/// @param amount - to borrow from this offer
/// @param offer intended for usage in the loan
struct OfferArgs {
    bytes signature;
    uint256 amount;
    Offer offer;
}

/// @notice Data on collateral state during the matching process of a NFT
///     with multiple offers
/// @param matched proportion from 0 to 1 of the collateral value matched by offers
/// @param assetLent - ERC20 that the protocol will send as loan
/// @param minOfferDuration minimal duration among offers used
/// @param from original owner of the nft (borrower in most cases)
/// @param nft the collateral asset
/// @param loanId loan identifier
struct CollateralState {
    Ray matched;
    IERC20 assetLent;
    uint256 minOfferDuration;
    address from;
    NFToken nft;
    uint256 loanId;
}

/// @notice Loan offer
/// @param assetToLend address of the ERC-20 to lend
/// @param loanToValue amount to lend per collateral
/// @param duration in seconds, time before mandatory repayment after loan start
/// @param expirationDate date after which the offer can't be used
/// @param tranche identifies the interest rate tranche
/// @param collateral the NFT that can be used as collateral with this offer
struct Offer {
    IERC20 assetToLend;
    uint256 loanToValue;
    uint256 duration;
    uint256 expirationDate;
    uint256 tranche;
    NFToken collateral;
}

/// @title Non Fungible Token
/// @notice describes an ERC721 compliant token, can be used as single spec
///     I.e Collateral type accepting one specific NFT
/// @param implem address of the NFT contract
/// @param id token identifier
struct NFToken {
    IERC721 implem;
    uint256 id;
}
