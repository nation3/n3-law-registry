#!/bin/bash
trap 'kill $BGPID; exit' INT
anvil &    # background command
BGPID=$!
sleep 1
forge script packages/contracts/script/Deploy.s.sol:Deploy --fork-url "http://localhost:8545" --broadcast
yarn workspace @linkedpm/sdk test

# on exit
killall -9 anvil