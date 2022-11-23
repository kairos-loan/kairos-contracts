// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./Storage.sol";
import "./ERC721Errors.sol";

error UnknownCollatSpecType(CollatSpecType);
error NFTContractDoesntMatchOfferSpecs(IERC721 sentCollat, IERC721 offerCollat);
error TokenIdDoesntMatchOfferSpecs(uint256 sentTokenId, uint256 offerTokenId);
error CollateralDoesntMatchSpecs(IERC721 sentCollateral, uint256 tokenId);
error OfferNotFound(Offer offer, Root merkleTreeRoot);
error OfferHasExpired(Offer offer, uint256 expirationDate);
error RequestedAmountTooHigh(uint256 requested, uint256 offered);
error InconsistentAssetRequests(IERC20 firstRequested, IERC20 requested);
error LoanAlreadyRepaid(uint256 loanId);
error SupplyPositionDoesntBelongToTheLoan(uint256 positionId, uint256 loanId);
error NotBorrowerOfTheLoan(uint256 loanId);
error BorrowerAlreadyClaimed(uint256 loanId);
