// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Open questions : 
// - Q Will offers actually be stored anywhere ?
// - A Probably yes for issuing lender NFT I.e bond

/// @notice 27-decimals fixed point unsigned number
/// @member ray value
struct Ray {
    uint256 ray;
}

/// @notice General protocol parameters
/// @member rateOfTranche interest rate of tranche of provided id, in multiplier per second
struct Protocol {
    mapping(uint256 => Ray) rateOfTranche;
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
    uint256 collateralSpecType;
    uint256 tranche;
    bytes collateralSpecs;
}

/// @notice Issued Loan (corresponding to one collateral)
/// @member assetLent currency lent
/// @member lent total amount lent
/// @member endDate timestamp after which sale starts & repay is impossible
/// @member tranche identifies the interest rate tranche
/// @member borrower borrowing account
/// @member collateral NFT contract of collateral
/// @member tokenId identifies the collateral in his collection
/// @member nbOfSuppliers number of suppliers
/// @member matchedOffer matched offer by id
/// @member suppliedBy amount supplied 
struct Loan {
    IERC20 assetLent;
    uint256 lent;
    uint256 endDate;
    uint256 tranche;
    address borrower;
    IERC721 collateral;
    uint256 tokenId;
    uint256 nbOfSuppliers;
    mapping(uint256 => Offer) matchedOffer;
    mapping(uint256 => uint256) suppliedBy;
}