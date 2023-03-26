// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import "forge-std/Test.sol";
import {DocRegistryL2} from "../src/DocRegistryL2.sol";
import {IDocRegistryL2} from "../src/IDocRegistryL2.sol";

import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";

contract L2RegistryTest is Test, DSTestPlus {
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
        DocRegistryL2 reg = new DocRegistryL2();

        reg.claimZone("hello world");
        assertEq(reg.balanceOf(address(this)), 1);
        assertEq(reg.ownerOf(0), address(this));

        reg.claimZone("hello world 2");
        assertEq(reg.balanceOf(address(this)), 2);
        assertEq(reg.ownerOf(1), address(this));
    }

    function testAddAgreement() public {
        DocRegistryL2 reg = new DocRegistryL2();

        reg.claimZone("zone");
        assertEq(reg.balanceOf(address(this)), 1);
        assertEq(reg.ownerOf(0), address(this));

        reg.updateAgreement(
            0, // zone
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
        DocRegistryL2 reg = new DocRegistryL2();

        reg.claimZone("zone");
        assertEq(reg.balanceOf(address(this)), 1);
        assertEq(reg.ownerOf(0), address(this));

        reg.updateAgreement(
            0, // zone
            keccak256("key"), // key
            "revision",
            keccak256("value")
        );

        reg.updateAgreement(
            0, // zone
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

    function testCannotUpdateAgreementAsNotOwner() public {
        DocRegistryL2 reg = new DocRegistryL2();

        reg.claimZone("zone");
        assertEq(reg.balanceOf(address(this)), 1);
        assertEq(reg.ownerOf(0), address(this));

        vm.expectRevert(IDocRegistryL2.Unauthorized.selector);
        vm.prank(address(0x333));

        reg.updateAgreement(
            0, // zone
            keccak256("key"), // key
            "revision",
            keccak256("value")
        );
    }

    function testCannotUpdateRevisionAsOwner() public {
        DocRegistryL2 reg = new DocRegistryL2();

        reg.claimZone("zone");
        assertEq(reg.balanceOf(address(this)), 1);
        assertEq(reg.ownerOf(0), address(this));
        reg.updateAgreement(
            0, // zone
            keccak256("key"), // key
            "revision",
            keccak256("value")
        );

        vm.expectRevert(bytes("exists"));

        reg.updateAgreement(
            0, // zone
            keccak256("key"), // key
            "revision",
            keccak256("value2")
        );
    }

    function testGetAgreementData() public {
        DocRegistryL2 reg = new DocRegistryL2();

        reg.claimZone("zone");
        assertEq(reg.balanceOf(address(this)), 1);
        assertEq(reg.ownerOf(0), address(this));

        reg.updateAgreement(
            0, // zone
            keccak256("key"), // key
            "revision",
            keccak256("value")
        );

        bytes32 agreementData = reg.zoneAgreement(
            uint256(0),
            keccak256("key"),
            keccak256("revision")
        );

        assertEq(agreementData, keccak256("value"));
    }

    function testGetLatestAgreement() public {
        DocRegistryL2 reg = new DocRegistryL2();

        reg.claimZone("zone");
        assertEq(reg.balanceOf(address(this)), 1);
        assertEq(reg.ownerOf(0), address(this));

        reg.updateAgreement(
            0, // zone
            keccak256("key"), // key
            "revision",
            keccak256("value")
        );
        reg.updateAgreement(
            0, // zone
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
        DocRegistryL2 reg = new DocRegistryL2();

        reg.claimZone("zone");
        assertEq(reg.name(keccak256("zone")), "zone");
    }

    function testZoneIDName() public {
        DocRegistryL2 reg = new DocRegistryL2();

        reg.claimZone("zone");
        assertEq(reg.name(uint256(0)), "zone");
    }

    function testZoneID() public {
        DocRegistryL2 reg = new DocRegistryL2();

        reg.claimZone("zone");
        assertEq(reg.zoneID(keccak256("zone")), 0);
    }

    function testZoneOwner() public {
        DocRegistryL2 reg = new DocRegistryL2();

        reg.claimZone("zone");
        assertEq(reg.ownerOf(0), address(this));
        assertEq(reg.ownerOf(0), reg.zoneOwner(keccak256("zone")));
    }

    function testCannotClaimExistingZone() public {
        DocRegistryL2 reg = new DocRegistryL2();

        reg.claimZone("zone");

        vm.expectRevert(bytes("no minty twice"));
        reg.claimZone("zone");
    }
}
