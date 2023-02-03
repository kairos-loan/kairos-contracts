#!/bin/bash

# Remove previous info of last deploy
# Used to sync between container
rm -rf /usr/app/packages/shared/src/generated/deployment.json

# Start blockchain node
anvil --silent --block-time 1 --allow-origin "*" --host 0.0.0.0 > out/anvil-logs.txt & PID_ANVIL=$!

# Wait install state to be ready
/usr/bin/wait

# Watch contract change to rebuild an deploy
# And then build and deploy the contract
export ENTR_INOTIFY_WORKAROUND=true;
while sleep 1; do 
  find packages/contracts -type f -name "*.sol"  | entr -d -n sh -c '
    echo "Start to build contract"
    forge build --use=/usr/bin/solc --extra-output-files abi

    echo "Start to generate types"
    yarn gen-typechain

    echo "Start to deploy contract"
    yarn dot-env && forge script ./packages/contracts/script/DeployLocal.s.sol -f http://contracts:8545 --no-auto-detect --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

    echo "Finished. Watching for new change"
  '; 
done
