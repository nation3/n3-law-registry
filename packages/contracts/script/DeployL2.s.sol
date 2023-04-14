// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18;

import {Script} from "forge-std/Script.sol";
import {DocRegistryL2} from "../src/DocRegistryL2.sol";

contract Deploy is Script {
    address internal deployer;
    /// List all contracts you want to deploy
    DocRegistryL2 internal registry;

    function setUp() public virtual {
        (deployer, ) = deriveRememberKey(vm.envString("MNEMONIC"), 0);
    }

    function run() public {
        vm.broadcast(deployer);
        registry = new DocRegistryL2();
    }
}
