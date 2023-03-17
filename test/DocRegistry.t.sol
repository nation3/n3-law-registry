// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18;

import "forge-std/Test.sol";
import {DocRegistry} from "../src/DocRegistry.sol";
import {Multihash, IDocRegistry} from "../src/IDocRegistry.sol";

contract RegistryTest is Test {
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
            Multihash(keccak256("value"), 0x12, 0x20)
        );

        assert(
            reg.zoneAgreement(keccak256("zone"), keccak256("key"), 0).hash ==
                keccak256("value")
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
            Multihash(keccak256("value"), 0x12, 0x20)
        );

        reg.updateAgreement(
            keccak256("zone"), // zone
            keccak256("key"), // key
            Multihash(keccak256("value2"), 0x12, 0x20)
        );

        assert(
            reg.zoneAgreement(keccak256("zone"), keccak256("key"), 0).hash ==
                keccak256("value")
        );
        assert(
            reg.zoneAgreement(keccak256("zone"), keccak256("key"), 1).hash ==
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
            Multihash(keccak256("value"), 0x12, 0x20)
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
            Multihash(keccak256("value"), 0x12, 0x20)
        );

        Multihash memory agreementData = reg.zoneAgreement(
            keccak256("zone"),
            keccak256("key"),
            0
        );

        assertEq(agreementData.hash, keccak256("value"));
        assertEq(agreementData.hash_function, 0x12);
        assertEq(agreementData.size, 0x20);
    }

    function testGetLatestAgreement() public {
        DocRegistry reg = new DocRegistry();

        reg.claimZone("zone");
        assertEq(reg.balanceOf(address(this)), 1);
        assertEq(reg.ownerOf(uint256(keccak256("zone"))), address(this));

        reg.updateAgreement(
            keccak256("zone"), // zone
            keccak256("key"), // key
            Multihash(keccak256("value"), 0x12, 0x20)
        );
        reg.updateAgreement(
            keccak256("zone"), // zone
            keccak256("key"), // key
            Multihash(keccak256("value2"), 0x12, 0x20)
        );

        uint256 latest = reg.latestAgreement(
            keccak256("zone"),
            keccak256("key")
        );

        assertEq(latest, 1);
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
            Multihash(keccak256("value2"), 0x12, 0x20)
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
            Multihash(keccak256("value2"), 0x12, 0x20)
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
            Multihash(keccak256("value2"), 0x12, 0x20)
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
