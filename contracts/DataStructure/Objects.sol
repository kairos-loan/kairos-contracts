// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../interface/IERC721.sol";

/// @notice file for type definitions not used in storage

/// @notice 27-decimals fixed point unsigned number
type Ray is uint256;

// todo #29 fix singular/plural forms of args

/// @notice Arguments to buy the collateral of one loan
/// @member loanId loan identifier
/// @member to address that will receive the collateral
/// @member positionIds eventual supply positions to burn to reduce totally or partially the sale price
struct BuyArgs {
    uint256 loanId;
    address to;
    uint256[] positionIds;
}

/// @notice Arguments to borrow from one collateral
/// @member nft asset to use as collateral
/// @member args arguments for the borrow parameters of the offers to use with the collateral
struct BorrowArgs {
    NFToken nft;
    OfferArgs[] args;
}

/// @notice Arguments for the borrow parameters of an offer
/// @dev '-' means n^th
/// @member signature - of the offer
/// @member amount - to borrow from this offer
/// @member offer intended for usage in the loan
struct OfferArgs {
    bytes signature;
    uint256 amount;
    Offer offer;
}

/// @notice Data on collateral state during the matching process of a NFT
///     with multiple offers
/// @member matched proportion from 0 to 1 of the collateral value matched by offers
/// @member assetLent - ERC20 that the protocol will send as loan
/// @member minOfferDuration minimal duration among offers used
/// @member from original owner of the nft (borrower in most cases)
/// @member nft the collateral asset
/// @member loanId loan identifier
struct CollateralState {
    Ray matched;
    IERC20 assetLent;
    uint256 minOfferDuration;
    address from;
    NFToken nft;
    uint256 loanId;
}

/// @notice Loan offer
/// @member assetToLend address of the ERC-20 to lend
/// @member loanToValue amount to lend per collateral unit
/// @member duration in seconds, time before mandatory repayment after loan start
/// @member expirationDate date after which the offer can't be used
/// @member tranche identifies the interest rate tranche
/// @member collateral the NFT that can be used as collateral with this offer
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
/// @member implem address of the NFT contract
/// @member id token identifier
struct NFToken {
    IERC721 implem;
    uint256 id;
}
