// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18;

import {Script} from "forge-std/Script.sol";
import {DocRegistry} from "../src/DocRegistry.sol";

contract Deploy is Script {
    address internal deployer;
    /// List all contracts you want to deploy
    DocRegistry internal registry;

    function setUp() public virtual {
        (deployer, ) = deriveRememberKey(vm.envString("MNEMONIC"), 0);
    }

    function run() public {
        vm.startBroadcast(deployer);
        // deploy foo
        registry = new DocRegistry();
        vm.stopBroadcast();
    }
}
