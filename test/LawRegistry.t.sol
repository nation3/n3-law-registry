// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18;

import "forge-std/Test.sol";
import {LawRegistry} from "../src/LawRegistry.sol";
import {Multihash, ILawRegistry} from "../src/ILawRegistry.sol";

contract RegistryTest is Test {
    function testClaimZone() public {
        LawRegistry reg = new LawRegistry();
        reg.claimZone("hello world");
        assertEq(reg.balanceOf(address(this)), 1);
        assertEq(reg.ownerOf(uint256(keccak256("hello world"))), address(this));
    }

    function testAddAgreement() public {
        LawRegistry reg = new LawRegistry();

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
        LawRegistry reg = new LawRegistry();

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
        LawRegistry reg = new LawRegistry();

        reg.claimZone("zone");
        assertEq(reg.balanceOf(address(this)), 1);
        assertEq(reg.ownerOf(uint256(keccak256("zone"))), address(this));

        vm.expectRevert(ILawRegistry.Unauthorized.selector);
        vm.prank(address(0x333));

        reg.updateAgreement(
            keccak256("zone"), // zone
            keccak256("key"), // key
            Multihash(keccak256("value"), 0x12, 0x20)
        );
    }

    function testGetAgreementData() public {
        LawRegistry reg = new LawRegistry();

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
        LawRegistry reg = new LawRegistry();

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
        LawRegistry reg = new LawRegistry();

        reg.pauseZoneClaims();

        vm.expectRevert(LawRegistry.GlobalPaused.selector);

        reg.claimZone("zone");
    }

    function testPauseUpdatesGlobal() public {
        LawRegistry reg = new LawRegistry();

        reg.claimZone("zone");
        assertEq(reg.balanceOf(address(this)), 1);
        assertEq(reg.ownerOf(uint256(keccak256("zone"))), address(this));

        reg.pauseAgreementUpdates();

        vm.expectRevert(LawRegistry.GlobalPaused.selector);

        reg.updateAgreement(
            keccak256("zone"), // zone
            keccak256("key"), // key
            Multihash(keccak256("value2"), 0x12, 0x20)
        );
    }

    function testPauseUpdatesZone() public {
        LawRegistry reg = new LawRegistry();

        reg.claimZone("zone");
        assertEq(reg.balanceOf(address(this)), 1);
        assertEq(reg.ownerOf(uint256(keccak256("zone"))), address(this));

        reg.pauseAgreementUpdates(keccak256("zone"));

        vm.expectRevert(LawRegistry.ZonePaused.selector);

        reg.updateAgreement(
            keccak256("zone"), // zone
            keccak256("key"), // key
            Multihash(keccak256("value2"), 0x12, 0x20)
        );
    }

    function testPauseUpdatesKey() public {
        LawRegistry reg = new LawRegistry();

        reg.claimZone("zone");
        assertEq(reg.balanceOf(address(this)), 1);
        assertEq(reg.ownerOf(uint256(keccak256("zone"))), address(this));

        reg.pauseAgreementUpdates(keccak256("zone"), keccak256("key"));

        vm.expectRevert(LawRegistry.KeyPaused.selector);

        reg.updateAgreement(
            keccak256("zone"), // zone
            keccak256("key"), // key
            Multihash(keccak256("value2"), 0x12, 0x20)
        );
    }

    function testZoneName() public {
        LawRegistry reg = new LawRegistry();

        reg.claimZone("zone");
        assertEq(reg.name(keccak256("zone")), "zone");
    }

    function testZoneID() public {
        LawRegistry reg = new LawRegistry();

        reg.claimZone("zone");
        assertEq(reg.zoneID(keccak256("zone")), uint256(keccak256("zone")));
    }

    function testZoneOwner() public {
        LawRegistry reg = new LawRegistry();

        reg.claimZone("zone");
        assertEq(reg.ownerOf(uint256(keccak256("zone"))), address(this));
        assertEq(
            reg.ownerOf(uint256(keccak256("zone"))),
            reg.zoneOwner(keccak256("zone"))
        );
    }

    function testCannotClaimExistingZone() public {
        LawRegistry reg = new LawRegistry();

        reg.claimZone("zone");

        vm.expectRevert(bytes("ERC721: token already minted"));
        reg.claimZone("zone");
    }

    function testCannotReclaimZoneAsUser() public {
        LawRegistry reg = new LawRegistry();

        reg.claimZone("zone");

        vm.startPrank(address(0x333));
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        reg.reclaimZone(keccak256("zone"));
        vm.stopPrank();
    }

    function testReclaimZone() public {
        LawRegistry reg = new LawRegistry();

        vm.prank(address(0x333));
        reg.claimZone("zone");

        assertEq(reg.ownerOf(uint256(keccak256("zone"))), address(0x333));

        reg.reclaimZone(keccak256("zone"));
        assertEq(reg.ownerOf(uint256(keccak256("zone"))), address(this));
    }
}
