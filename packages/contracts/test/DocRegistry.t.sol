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
        DSTestPlus.assertFalse(data);
    }

    function bound(
        uint256 x,
        uint256 min,
        uint256 max
    ) internal view override(StdUtils, DSTestPlus) returns (uint256) {
        return DSTestPlus.bound(x, min, max);
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
            keccak256("value"),
            0
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
            keccak256("value"),
            0
        );

        reg.updateAgreement(
            keccak256("zone"), // zone
            keccak256("key"), // key
            "revision2",
            keccak256("value2"),
            0
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
            keccak256("value"),
            0
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
            keccak256("value"),
            0
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
            keccak256("value"),
            0
        );
        reg.updateAgreement(
            keccak256("zone"), // zone
            keccak256("key"), // key
            "latest",
            keccak256("value2"),
            0
        );

        bytes32 latest = reg.zoneAgreement(
            keccak256("zone"),
            keccak256("key"),
            keccak256("latest")
        );

        assertEq(latest, keccak256("value2"));
    }

    function testPauseClaims() public {
        DocRegistry reg = new DocRegistry();

        reg.pauseZoneClaims();

        vm.expectRevert(DocRegistry.GlobalPaused.selector);

        reg.claimZone("zone");
    }

    function testPauseUpdatesGlobal() public {
        DocRegistry reg = new DocRegistry();

        reg.claimZone("zone");
        assertEq(reg.balanceOf(address(this)), 1);
        assertEq(reg.ownerOf(uint256(keccak256("zone"))), address(this));

        reg.pauseAgreementUpdates();

        vm.expectRevert(DocRegistry.GlobalPaused.selector);

        reg.updateAgreement(
            keccak256("zone"), // zone
            keccak256("key"), // key
            "pp",
            keccak256("value"),
            0
        );
    }

    function testPauseUpdatesZone() public {
        DocRegistry reg = new DocRegistry();

        reg.claimZone("zone");
        assertEq(reg.balanceOf(address(this)), 1);
        assertEq(reg.ownerOf(uint256(keccak256("zone"))), address(this));

        reg.pauseAgreementUpdates(keccak256("zone"));

        vm.expectRevert(DocRegistry.ZonePaused.selector);

        reg.updateAgreement(
            keccak256("zone"), // zone
            keccak256("key"), // key
            "pp",
            keccak256("value"),
            0
        );
    }

    function testPauseUpdatesKey() public {
        DocRegistry reg = new DocRegistry();

        reg.claimZone("zone");
        assertEq(reg.balanceOf(address(this)), 1);
        assertEq(reg.ownerOf(uint256(keccak256("zone"))), address(this));

        reg.pauseAgreementUpdates(keccak256("zone"), keccak256("key"));

        vm.expectRevert(DocRegistry.KeyPaused.selector);

        reg.updateAgreement(
            keccak256("zone"), // zone
            keccak256("key"), // key
            "pp",
            keccak256("value"),
            0
        );
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

    function testCannotReclaimZoneAsUser() public {
        DocRegistry reg = new DocRegistry();

        reg.claimZone("zone");

        vm.startPrank(address(0x333));
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        reg.reclaimZone(keccak256("zone"));
        vm.stopPrank();
    }

    function testReclaimZone() public {
        DocRegistry reg = new DocRegistry();

        vm.prank(address(0x333));
        reg.claimZone("zone");

        assertEq(reg.ownerOf(uint256(keccak256("zone"))), address(0x333));

        reg.reclaimZone(keccak256("zone"));
        assertEq(reg.ownerOf(uint256(keccak256("zone"))), address(this));
    }
}
