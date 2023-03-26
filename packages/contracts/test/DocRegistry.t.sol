// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import "forge-std/Test.sol";
import {DocRegistry} from "../src/DocRegistry.sol";
import {IDocRegistry} from "../src/IDocRegistry.sol";

import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";

contract RegistryTest is Test, DSTestPlus {
    function fail(string memory err)
        internal
        override(StdAssertions, DSTestPlus)
    {
        DSTestPlus.fail(err);
    }

    function assertFalse(bool data)
        internal
        override(StdAssertions, DSTestPlus)
    {
        StdAssertions.assertFalse(data);
    }

    function bound(
        uint256 x,
        uint256 min,
        uint256 max
    ) internal view virtual override(StdUtils, DSTestPlus) returns (uint256) {
        return StdUtils.bound(x, min, max);
    }

    function testClaimZone() public {
        DocRegistry reg = new DocRegistry();

        reg.claimZone("hello world");
        assertEq(reg.balanceOf(address(this)), 1);
        assertEq(reg.ownerOf(uint256(keccak256("hello world"))), address(this));
    }

    function testAddAgreement() public {
        DocRegistry reg = new DocRegistry();

        reg.claimZone("zone");
        assertEq(reg.balanceOf(address(this)), 1);
        assertEq(reg.ownerOf(uint256(keccak256("zone"))), address(this));

        reg.updateAgreement(
            keccak256("zone"), // zone
            keccak256("key"), // key
            "revision",
            keccak256("value")
        );

        assert(
            reg.zoneAgreement(
                keccak256("zone"),
                keccak256("key"),
                keccak256("revision")
            ) == keccak256("value")
        );
    }

    function testUpdateAgreement() public {
        DocRegistry reg = new DocRegistry();

        reg.claimZone("zone");
        assertEq(reg.balanceOf(address(this)), 1);
        assertEq(reg.ownerOf(uint256(keccak256("zone"))), address(this));

        reg.updateAgreement(
            keccak256("zone"), // zone
            keccak256("key"), // key
            "revision",
            keccak256("value")
        );

        reg.updateAgreement(
            keccak256("zone"), // zone
            keccak256("key"), // key
            "revision2",
            keccak256("value2")
        );

        assert(
            reg.zoneAgreement(
                keccak256("zone"),
                keccak256("key"),
                keccak256("revision")
            ) == keccak256("value")
        );
        assert(
            reg.zoneAgreement(
                keccak256("zone"),
                keccak256("key"),
                keccak256("revision2")
            ) == keccak256("value2")
        );
    }

    function testCannotUpdateSameRevisionAgreement() public {
        DocRegistry reg = new DocRegistry();

        reg.claimZone("zone");
        assertEq(reg.balanceOf(address(this)), 1);
        assertEq(reg.ownerOf(uint256(keccak256("zone"))), address(this));

        reg.updateAgreement(
            keccak256("zone"), // zone
            keccak256("key"), // key
            "revision",
            keccak256("value")
        );
        assert(
            reg.zoneAgreement(
                keccak256("zone"),
                keccak256("key"),
                keccak256("revision")
            ) == keccak256("value")
        );

        vm.expectRevert(bytes("exists"));
        reg.updateAgreement(
            keccak256("zone"), // zone
            keccak256("key"), // key
            "revision",
            keccak256("value2")
        );
    }

    function testCannotUpdateAgreement() public {
        DocRegistry reg = new DocRegistry();

        reg.claimZone("zone");
        assertEq(reg.balanceOf(address(this)), 1);
        assertEq(reg.ownerOf(uint256(keccak256("zone"))), address(this));

        vm.expectRevert(IDocRegistry.Unauthorized.selector);
        vm.prank(address(0x333));

        reg.updateAgreement(
            keccak256("zone"), // zone
            keccak256("key"), // key
            "revision",
            keccak256("value")
        );
    }

    function testGetAgreementData() public {
        DocRegistry reg = new DocRegistry();

        reg.claimZone("zone");
        assertEq(reg.balanceOf(address(this)), 1);
        assertEq(reg.ownerOf(uint256(keccak256("zone"))), address(this));

        reg.updateAgreement(
            keccak256("zone"), // zone
            keccak256("key"), // key
            "revision",
            keccak256("value")
        );

        bytes32 agreementData = reg.zoneAgreement(
            keccak256("zone"),
            keccak256("key"),
            keccak256("revision")
        );

        assertEq(agreementData, keccak256("value"));
    }

    function testGetLatestAgreement() public {
        DocRegistry reg = new DocRegistry();

        reg.claimZone("zone");
        assertEq(reg.balanceOf(address(this)), 1);
        assertEq(reg.ownerOf(uint256(keccak256("zone"))), address(this));

        reg.updateAgreement(
            keccak256("zone"), // zone
            keccak256("key"), // key
            "revision",
            keccak256("value")
        );
        reg.updateAgreement(
            keccak256("zone"), // zone
            keccak256("key"), // key
            "latest",
            keccak256("value2")
        );

        bytes32 latest = reg.zoneAgreement(
            keccak256("zone"),
            keccak256("key"),
            keccak256("latest")
        );

        assertEq(latest, keccak256("value2"));
    }

    function testZoneName() public {
        DocRegistry reg = new DocRegistry();

        reg.claimZone("zone");
        assertEq(reg.name(keccak256("zone")), "zone");
    }

    function testZoneID() public {
        DocRegistry reg = new DocRegistry();

        reg.claimZone("zone");
        assertEq(reg.zoneID(keccak256("zone")), uint256(keccak256("zone")));
    }

    function testZoneOwner() public {
        DocRegistry reg = new DocRegistry();

        reg.claimZone("zone");
        assertEq(reg.ownerOf(uint256(keccak256("zone"))), address(this));
        assertEq(
            reg.ownerOf(uint256(keccak256("zone"))),
            reg.zoneOwner(keccak256("zone"))
        );
    }

    function testCannotClaimExistingZone() public {
        DocRegistry reg = new DocRegistry();

        reg.claimZone("zone");

        vm.expectRevert(bytes("ERC721: token already minted"));
        reg.claimZone("zone");
    }
}
