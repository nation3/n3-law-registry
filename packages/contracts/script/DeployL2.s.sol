// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18;

import {Script} from "forge-std/Script.sol";
import {DocRegistryL2} from "../src/DocRegistryL2.sol";
import {console} from "forge-std/console.sol";

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

        string memory x = vm.serializeAddress("index", "a", address(registry));
        vm.writeJson(
            x,
            string.concat(
                "./packages/contracts/out/deploy-",
                vm.toString(getChainID()),
                "-",
                vm.toString(block.timestamp),
                ".json"
            )
        );
        vm.writeJson(
            x,
            string.concat(
                "./packages/contracts/out/deploy-",
                vm.toString(getChainID()),
                "-latest",
                ".json"
            )
        );

        console.log("L2 registry addr:", address(registry));
    }

    function getChainID() public view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }
}
