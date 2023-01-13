// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {NFToken, Offer} from "./Objects.sol";

error CollateralDoesntMatchSpecs(IERC721 sentCollateral, uint256 tokenId);
error BadCollateral(Offer offer, NFToken providedNft);
error OfferHasExpired(Offer offer, uint256 expirationDate);
error RequestedAmountIsNull(Offer offer);
error RequestedAmountTooHigh(uint256 requested, uint256 offered);
error InconsistentAssetRequests(IERC20 firstRequested, IERC20 requested);
error LoanAlreadyRepaid(uint256 loanId);
error SupplyPositionDoesntBelongToTheLoan(uint256 positionId, uint256 loanId);
error NotBorrowerOfTheLoan(uint256 loanId);
error BorrowerAlreadyClaimed(uint256 loanId);
