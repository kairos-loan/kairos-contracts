# KAIROS LOAN

NFT as collateral lending protocol. Real name TBD.

## test

`forge test`

## deploy locally

`forge script contracts/script/Deploy.s.sol -f http://localhost:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80`

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
