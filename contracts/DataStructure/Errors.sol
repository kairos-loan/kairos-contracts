// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "./Storage.sol";

error UnknownCollatSpecType(CollatSpecType);
error NFTContractDoesntMatchOfferSpecs(IERC721 sentCollat, IERC721 offerCollat);
error TokenIdDoesntMatchOfferSpecs(uint256 sentTokenId, uint256 offerTokenId);
error CollateralDoesntMatchSpecs(IERC721 sentCollateral, uint256 tokenId);
error OfferNotFound(Offer offer, Root merkleTreeRoot);
error OfferHasBeenDeleted(Offer offer, uint256 currentSupplierNonce);
error RequestedAmountTooHigh(uint256 requested, uint256 offered);
error InconsistentAssetRequests(IERC20 firstRequested, IERC20 requested);
