// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../interface/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice file for type definitions not used in storage

/// @notice type ids for collateral specification
/// @member Floor any NFT in a collection is accepted
enum CollatSpecType {
    Floor,
    Single
}

/// @notice 27-decimals fixed point unsigned number
type Ray is uint256;

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
///     possible opti is to use OZ's multiProofVerify func, not used here
///     because it can mess with the ordering of the offer usage
/// @member proof - of the offer inclusion in his tree
/// @member root - of the supplier offer merkle tree
/// @member signature - of the supplier offer merkle tree root
/// @member amount - to borrow from this offer
/// @member offer intended for usage in the loan
struct OfferArgs {
    bytes32[] proof;
    Root root;
    bytes signature;
    uint256 amount;
    Offer offer;
}

/// @notice Data on collateral state during the matching process of a NFT
///     with multiple offers
/// @member matched proportion from 0 to 1 of the collateral value matched by offers
/// @member assetLent - ERC20 that the protocol will send as loan
/// @member minOfferDuration minimal duration among offers used
/// @member from original owner of the nft
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
/// @member nonce used to determine if the offer is still valid
/// @member collateralSpecType identifies logic to establish validity of an asset
/// @member tranche identifies the interest rate tranche
/// @member collateralSpecs abi-encoded arguments for the validity checker
struct Offer {
    IERC20 assetToLend;
    uint256 loanToValue;
    uint256 duration;
    uint256 nonce;
    CollatSpecType collatSpecType;
    uint256 tranche;
    bytes collatSpecs;
}

/// @dev Add "Spec" as suffix to structs meant for describing collaterals

/// @notice Collateral type accepting any NFT of a collection
/// @dev we use struct with a single member to keep the type check on
///     collateral being an IERC721
/// @member implem NFT contract I.e collection
struct FloorSpec {
    IERC721 implem;
}

/// @notice Root of a supplier offer merkle tree
/// @dev we use a struct with a single member to sign in the EIP712 fashion
///     so signed roots are only available for the desired contract on desired chain
/// @member root the merkle root
struct Root {
    bytes32 root;
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
