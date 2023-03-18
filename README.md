# KAIROS LOAN

NFT as collateral lending protocol. Contracts repository

## Docs

Documentation has been moved to the [kairos book](https://doc.kairos.loan).

## Install

```sh
npm i
```

Kairos uses [`foundry`](https://book.getfoundry.sh/) as development framework,
[install](https://book.getfoundry.sh/getting-started/installation) it to use
this repository.

## Test

```sh
forge test
```

### Test architecture

In the `test/Commons` folder are helpers and not actual tests.
[`TestCommons`](test/Commons/TestCommons.sol) has general helpers. An example of the contract deployment can be found in [`SetUp`](test/Commons/SetUp.sol). [`Loggers`](test/Commons/Loggers.sol) exposes methods to look into structs. Contracts testing external methods inherit from [`External`](test/Commons/External.sol) that exposes the `kairos` contract diamond. Contracts testing internal methods inherit from [`Internal`](test/Commons/Internal.sol) that itself contains all internal methods normally found in multiple facets in the same contract by extending [`BigKairos`](test/Commons/BigKairos.sol).

## ."something".sol reference

- .h as "header" for function selectors getters
- .s as "script"
- .t as "test"

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
