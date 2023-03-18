# KAIROS LOAN

NFT as collateral lending protocol. Contracts repository

## Docs

Documentation has been moved to the [kairos book](https://doc.kairos.loan).

### ."something".sol reference

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
- Check out the generated [report](./out/slither-report.md) and [functions summary](./out/slither-functions-summary.txt)
