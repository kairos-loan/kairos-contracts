# KAIROS LOAN

NFT as collateral lending protocol. Contracts repository

## Design & architecture

The Kairos protocol is accessible behind a single address despite consisting of multiple upgradable smart-contracts thanks to being a [diamond](https://eips.ethereum.org/EIPS/eip-2535).

### Supplying

Suppliers make offers by signing messages with their private keys and giving allowance on their tokens to the protocol.  
Offers must be of [`Offer`](src/DataStructure/Objects.sol) type, and be signed by the private key of the account providing the tokens. The signature must be of the output of [`offerDigest()`](src/Signature.sol) which is [EIP712](https://eips.ethereum.org/EIPS/eip-712)-compliant.

### Borrowing

Borrowing can be achieved in two ways :

1. Through sending an NFT to the contract, triggering [`onERC721Received()`](src/BorrowFacet.sol) callback (make sure to put [`OfferArg[]`](src/DataStructure/Objects.sol)-formatted arguments in the `data` field).
2. By calling the [`borrow()`](src/BorrowFacet.sol) method. NFTs that will be used as collateral must have been approved to the contract before the call.

In every case, the arguments should contain loan offers with their corresponding signatures issued by its suppliers. Those will be checked (signer address computed) and if valid, requested amount will be transferred directly from supplier to borrower. NFT provided as collateral will be taken in the protocol contract (kairos will support letting them in borrower's account soon) and a NFT representing the supply position is issued and sent to the supplier.  
From the contract's standpoint, a loan has only one collateral, but can have multiple offers (and therefore suppliers) used to issue it. Public-facing methods always allow to borrow/repay/liquidate/claim multiple loans in one call so this multiplicity is abstracted in user experience.

### Interests

Interests on loans accrue linearly according to the [`getLoan(<id>).interestPerSecond`](src/ProtocolFacet.sol) rate fixed at issuance.

### Repaying

The [`getLoan(<id>).endDate`](src/ProtocolFacet.sol) limit date is fixed at issuance and corresponding to the minimal value of [`Offer.duration`](src/DataStructure/Objects.sol) in offers used, added to the issuance date. After this date and if the loan is not repaid, the collateral is on sale for liquidation. Borrowers can repay at any time, even after limit date, as long as the collateral is not liquidated. Repay through [`repay()`](src/RepayFacet.sol). Give approval on your tokens used for repayment before the call.

### Buying in auction

The [`buy()`](src/AuctionFacet.sol) method allows to take ownership of an NFT collateral in liquidation. The price is determined following a linear dutch auction, duration and initial price being fixed by [`getParameters().auction.duration`](src/ProtocolFacet.sol) and [`getParameters().auction.priceFactor`](src/ProtocolFacet.sol) (no oracle involved). The borrower and the suppliers of the corresponding loan experience reduced price according to the following principle : they don't pay twice for what they already provided. As a borrower if you didn't borrowed the full loan to value of the collateral, you only have to pay the share of the value you borrowed. As a supplier, provide your position ids in the arguments to burn them and pay only for the share you didn't already lent for. Give approval on your tokens used for purchase before the call.

### Claiming

Call [`claim()`](src/ClaimFacet.sol) as a supplier to get back principal + interests on the amount you lent. Use the same method to get your share of a liquidation. As a borrower, you can claim the value of your liquidated collateral that you didn't borrow, call [`claimAsBorrower()`](src/ClaimFacet.sol).

### Administration

The protocol owner have the ability to change the two (duration and price factor) parameters of auctions at any time.
The change is only applied for loans issued after the modification. Loans already issued will liquidate their
collateral if necessary following the parameters active at the time of issuance. The protocol owner can also create new
interest rate tranches for the lenders to supply on.

### Fees

No DAO fee is taken yet, but please note that it will be the case in the future. They may be taken on one or multiple of the following sources : borrow, interests, liquidation or elsewhere. This is needed for retro-active and future funding of the protocol development and other DAO expenses. All decisions regarding fee collection and treasury usage will be taken in public.

### ."something".sol reference

- .h as "header" for function selectors getters
- .s as "script"
- .t as "test"
- .f as "facet"

## Deploying

.env vars expected :

- _GOERLI_URL_
- _DEPLOYER_KEY_

## Developing

### Imports style policy

first import external dependencies (such as the ones from open zeppelin)  
leave a blank line
then import interfaces (if they are from this repo)  
leave another blank line  
finally import local code files

### Remappings

When we add a new dependency we should update:

- [.vscode/settings.json](../../.vscode/settings.json#L26-L31)
- [packages/contracts/scripts/sh/slither.sh](scripts/sh/slither.sh#L2)
- [packages/contracts/foundry.toml](foundry.toml#L9-L14)

### Adding a facet

- [ ] implement
- [ ] test
- [ ] natspec
- [ ] interface
- [ ] create its [function selector getters](src/utils/FuncSelectors.h.sol)
- [ ] add it to [contracts creator's](src/ContractsCreator.sol) `createContracts()`
- [ ] add it to [contracts creator's](src/ContractsCreator.sol) `getFacetCuts()`
- [ ] add it to [deployFunc's](scripts/ts/deployFunc.ts) facetNames
- [ ] add it to [IKairos](src/interface/IKairos.sol)
- [ ] add it to [BigKairos](test/Commons/BigKairos.sol)
- [ ] add it to the docs

It's working out of the box with hardhat if dependencies are under `node_modules`.
The issue [#325](https://github.com/kairos-loan/monorepo/issues/325) is created to resolve this duplication.

### Slither (Solidity static analysis)

- Install [solc v0.8.18](https://docs.soliditylang.org/en/v0.8.18/installing-solidity.html)
- Install [slither](https://github.com/crytic/slither#how-to-install) (avoid Docker installation)
- Run `yarn slither`
- Check the report generated by slither in `slither-report.md`
