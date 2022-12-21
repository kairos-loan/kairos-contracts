# KAIROS LOAN

NFT as collateral lending protocol. Contracts repository

# Design & architecture

The Kairos protocol is accessible behind a single address despite consisting of multiple upgradable smart-contracts thanks to being a [diamond](https://eips.ethereum.org/EIPS/eip-2535).

## Supplying

Suppliers make offers by signing messages with their private keys and giving allowance on their tokens to the protocol.  
Offers must be of [`Offer`](contracts/src/DataStructure/Objects.sol) type, and be signed by the private key of the account providing the tokens. The signature must be of the output of [`offerDigest()`](contracts/src/Signature.sol) which is [EIP712](https://eips.ethereum.org/EIPS/eip-712)-compliant.

## Borrowing

Borrowing can be achieved in two ways :

1. Through sending an NFT to the contract, triggering [`onERC721Received()`](contracts/src/BorrowFacet.sol) callback (make sure to put [`OfferArgs[]`](contracts/src/DataStructure/Objects.sol)-formated arguments in the `data` field).
2. By calling the [`borrow()`](contracts/src/BorrowFacet.sol) method. NFTs that will be used as collateral must have been approved to the contract before the call.

In every case, the arguments should contain loan offers with their corresponding signatures issued by its suppliers. Those will be checked (signer address computed) and if valid, requested amount will be transferred directly from supplier to borrower. NFT provided as collateral will be taken in the protocol contract (kairos will support letting them in borrower's account soon) and a NFT representing the supply position is issued and sent to the supplier.  
From the contract's standpoint, a loan has only one collateral, but can have multiple offers (and therefore suppliers) used to issue it. Public-facing methods always allow to borrow/repay/liquidate/claim multiple loans in one call so this multiplicity is abstracted in user experience.

## Interests

Interests on loans accrue linearly according to the [`getLoan(<id>).interestPerSecond`](contracts/src/ProtocolFacet.sol) rate fixed at issuance.

## Repaying

The [`getLoan(<id>).endDate`](contracts/src/ProtocolFacet.sol) limit date is fixed at issuance and corresponding to the minimal value of [`Offer.duration`](contracts/src/DataStructure/Objects.sol) in offers used, added to the issuance date. After this date and if the loan is not repaid, the collateral is on sale for liquidation. Borrowers can repay at any time, even after limit date, as long as the collateral is not liquidated. Repay through [`repay()`](contracts/src/RepayFacet.sol). Give approval on your tokens used for repayment before the call.

## Buying in auction

The [`buy()`](contracts/src/AuctionFacet.sol) method allows to take ownership of an NFT collateral in liquidation. The price is determined following a linear dutch auction, duration and initial price being fixed by [`getParameters().auctionDuration`](contracts/src/ProtocolFacet.sol) and [`getParameters().auctionPriceFactor`](contracts/src/ProtocolFacet.sol) (no oracle involved). The borrower and the suppliers of the corresponding loan experience reduced price according to the following principle : they don't pay twice for what they already provided. As a borrower if you didn't borrowed the full loan to value of the collateral, you only have to pay the share of the value you borrowed. As a supplier, provide your position ids in the arguments to burn them and pay only for the share you didn't already lent for. Give approval on your tokens used for purchase before the call.

## Claiming

Call [`claim()`](contracts/src/ClaimFacet.sol) as a supplier to get back principal + interests on the amount you lent. Use the same method to get your share of a liquidation. As a borrower, you can claim the value of your liquidated collateral that you didn't borrow, call [`claimAsBorrower()`](contracts/src/ClaimFacet.sol).

## Fees

No DAO fee is taken yet, but please note that it will be the case in the future. They may be taken on one or multiple of the following sources : borrow, interests, liquidation or elsewhere. This is needed for retro-active and future funding of the protocol development and other DAO expenses. All decisions regarding fee collection and treasury usage will be taken in public.

# Dev

## setup

Copy and fill files that contains a `.example` in their name.  
Check out the [`package.json`](package.json) for some useful commands.

## Dependencies

Use yarn.

## Code style policies

Abreviations in naming is tolerated  
No abreviation if the abreviated word is the whole name

- "collat" is "collateral"
- "SP" is "storage position"
- "FS" is "function selectors"
- "sig" is "signature"
- "temp" is "temporary"
- "func" is "function"
- "implem" is "implementation"
- "DS" is "Data Structure"
- "OZ" is "Open Zeppelin"
- "exec" is "execute"
- "init" is "initialize"
- "ret" is "returned"
- "prod" is "production"

respect solhint warnings and errors  
No file longer than 150 lines  
use singular for mapping names, plural for arrays  
never ever copy paste, find & destroy code duplication

## Repository management policy

branches must follow the git-flow pattern  
only merge used  
use [Gitmoji](https://marketplace.visualstudio.com/items?itemName=seatonjiang.gitmoji-vscode) in commit names

## ."something".sol reference

- .h as "header" for function selectors getters
- .s as "script"
- .t as "test"
- .f as "facet"
