// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./Storage.sol";
import "./ERC721Errors.sol";

error BadCollateral(Offer offer, NFToken providedNft);
error OfferHasExpired(Offer offer, uint256 expirationDate);
error RequestedAmountTooHigh(uint256 requested, uint256 offered);
error InconsistentAssetRequests(IERC20 firstRequested, IERC20 requested);
error LoanAlreadyRepaid(uint256 loanId);
error SupplyPositionDoesntBelongToTheLoan(uint256 positionId, uint256 loanId);
error NotBorrowerOfTheLoan(uint256 loanId);
error BorrowerAlreadyClaimed(uint256 loanId);
