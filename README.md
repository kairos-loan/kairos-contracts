# KAIROS LOAN

NFT as collateral lending protocol. Contracts repository

# Design & architecture

The Kairos protocol is accessible behind a single address despite consisting of multiple upgradable smart-contracts thanks to being a [diamond](https://eips.ethereum.org/EIPS/eip-2535).

## Supplying

Suppliers make offers by signing messages with their private keys and giving allowance on their tokens to the protocol.  
Offers must be of [`Offer`](contracts/DataStructure/Objects.sol) type, abi encoded and keccak256-hashed in leafs of a sorted merkle tree. Signatures must be
of the output of [`rootDigest(<the merkle tree root>)`](contracts/BorrowLogic/BorrowCheckers.sol).

## Supplier nonce

The [`offer.nonce`](contracts/DataStructure/Objects.sol) parameter should be seen as a way to control validity of the offers. Every offer is checked at borrow time against his signer's on-chain stored "nonce" and inequality results in a revert. Suppliers should sign new offers with [`getSupplierNonce(<signing address>)`](contracts/ProtocolFacet.sol) as value for [`offer.nonce`](contracts/DataStructure/Objects.sol). To make all offers unavailable (and provide new ones), call [`updateOffers()`](contracts/ProtocolFacet.sol).

## Borrowing

Borrowing can be achieved in two ways :

1. Through sending an NFT to the contract, triggering [`onERC721Received()`](contracts/BorrowFacet.sol) callback (make sure to put [`OfferArgs[]`](contracts/DataStructure/Objects.sol)-formated arguments in the `data` field).
2. By calling the [`borrow()`](contracts/BorrowFacet.sol) method. NFTs that will be used as collateral must have been approved to the contract before the call.

In every case, the arguments should contain loan offers with their corresponding signatures issued by its suppliers. Those will be checked (signer address computed, merkle proof verified) and if valid, requested amount will be transferred directly from supplier to borrower. NFT provided as collateral will be taken in the protocol contract (kairos will support letting them in borrower's account soon) and a NFT representing the supply position is issued and sent to the supplier.  
From the contract's standpoint, a loan has only one collateral, but can have multiple offers (and therefore suppliers) used to issue it. Public-facing methods always allow to borrow/repay/liquidate/claim multiple loans in one call so this multiplicity is abstracted in user experience.

## Interests

Interests on loans accrue linearly according to the [`getLoan(<id>).interestPerSecond`](contracts/ProtocolFacet.sol) rate fixed at issuance.

## Repaying

The [`getLoan(<id>).endDate`](contracts/ProtocolFacet.sol) limit date is fixed at issuance and corresponding to the minimal value of [`Offer.duration`](contracts/DataStructure/Objects.sol) in offers used, added to the issuance date. After this date and if the loan is not repaid, the collateral is on sale for liquidation. Borrowers can repay at any time, even after limit date, as long as the collateral is not liquidated. Repay through [`repay()`](contracts/RepayFacet.sol). Give approval on your tokens used for repayment before the call.

## Buying in auction

The [`buy()`](contracts/AuctionFacet.sol) method allows to take ownership of an NFT collateral in liquidation. The price is determined following a linear dutch auction, duration and initial price being fixed by [`getParameters().auctionDuration`](contracts/ProtocolFacet.sol) and [`getParameters().auctionPriceFactor`](contracts/ProtocolFacet.sol) (no oracle involved). The borrower and the suppliers of the corresponding loan experience reduced price according to the following principle : they don't pay twice for what they already provided. As a borrower if you didn't borrowed the full loan to value of the collateral, you only have to pay the share of the value you borrowed. As a supplier, provide your position ids in the arguments to burn them and pay only for the share you didn't already lent for. Give approval on your tokens used for purchase before the call.

## Claiming

Call [`claim()`](contracts/ClaimFacet.sol) as a supplier to get back principal + interests on the amount you lent. Use the same method to get your share of a liquidation. As a borrower, you can claim the value of your liquidated collateral that you didn't borrow, call [`claimAsBorrower()`](contracts/ClaimFacet.sol).

## Fees

No DAO fee is taken yet, but please note that it will be the case in the future. They may be taken on one or multiple of the following sources : borrow, interests, liquidation or elsewhere. This is needed for retro-active and future funding of the protocol development and other DAO expenses. All decisions regarding fee collection and treasury usage will be taken in public.

# Dev

## test

`forge test`

## deploy locally

`forge script contracts/script/Deploy.s.sol -f http://localhost:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80`  
(default private key of anvil/hardhat)

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

## Repository management policy

branches must follow the git-flow pattern  
only merge used  
use [Gitmoji](https://marketplace.visualstudio.com/items?itemName=seatonjiang.gitmoji-vscode) in commit names

## ."something".sol reference

- .h as "header" for function selectors getters
- .s as "script"
- .t as "test"
- .f as "facet"
