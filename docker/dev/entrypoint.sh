#!/bin/bash

# Remove previous info of last deploy
# Used to sync between container
rm -rf /usr/app/packages/contracts/out/deployment.env

# Start blockchain node
anvil --silent --block-time 1 --timestamp $(date +%s) --allow-origin "*" --host 0.0.0.0 > packages/contracts/out/anvil-logs.txt & PID_ANVIL=$!

# Wait install state to be ready
/usr/bin/wait

# Watch contract change to rebuild an deploy
# And then build and deploy the contract
export ENTR_INOTIFY_WORKAROUND=true;
while sleep 1; do 
  find packages/contracts -type f -name "*.sol"  | entr -d -n sh -c '  
    echo "Start to build contract"
    cd packages/contracts
    forge build --use=/usr/bin/solc --extra-output-files abi
    cd ../..

    echo "Start to generate types"
    cd packages/chain-types
    typechain --target ethers-v5 --out-dir ./out/tc ../contracts/out/foundry/BigKairos.sol/BigKairos.json ../contracts/out/foundry/ERC20.sol/ERC20.json ../contracts/out/foundry/ParamTypesGenerator.sol/ParamTypesGenerator.json ../contracts/out/foundry/DCHelperFacet.sol/DCHelperFacet.json ../contracts/out/foundry/DCTarget.sol/DCTarget.json ../contracts/out/foundry/Money.sol/Money.json ../contracts/out/foundry/NFT.sol/NFT.json
    cd ../..

    echo "Start to deploy contract"
    cd packages/contracts
    forge script ./scripts/sol/DeployLocal.s.sol -f http://contracts:8545 --no-auto-detect --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
    cd ../..

    echo "Finished. Watching for new change"
  '; 
done
