// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {NFToken, Offer} from "./Objects.sol";

error CollateralDoesntMatchSpecs(IERC721 sentCollateral, uint256 tokenId); // 0x9a295ec5
error BadCollateral(Offer offer, NFToken providedNft); // 0xd8ef221b
error ERC20TransferFailed(IERC20 token, address from, address to); // 0x62fe41f3
error OfferHasExpired(Offer offer, uint256 expirationDate); // 0x065a5c3b
error RequestedAmountIsNull(Offer offer); // 0x8ea5f1d7
error RequestedAmountTooHigh(uint256 requested, uint256 offered, Offer offer);
error InconsistentAssetRequests(IERC20 firstRequested, IERC20 requested); // 0x46aac2a9
error LoanAlreadyRepaid(uint256 loanId); // 0xdae2c273
error SupplyPositionDoesntBelongToTheLoan(uint256 positionId, uint256 loanId); // 0xf109be00
error NotBorrowerOfTheLoan(uint256 loanId); // 0xc250ea5d
error BorrowerAlreadyClaimed(uint256 loanId); // 0x16600edc
error CollateralIsNotLiquidableYet(uint256 endDate);
