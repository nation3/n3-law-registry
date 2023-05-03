// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IDocRegistryL2.sol";

/// @title L2 Linked Markdown Agreement Registry
/// @author sollee.eth
/// @notice Package manager for Linked Markdown
/// @dev Zone names MUST satisfy the following regex:
/// @dev   ([a-z0-9\-]{1,32})
/// @dev Agreement names MUST satisfy the following regex:
/// @dev   ([a-z0-9\-]{1,32})
/// @dev Revision names MUST satisfy the following regex:
/// @dev   ([a-z0-9\-\._]{1,32})
/// @dev A path MUST satisfy the following regex:
/// @dev   ^([a-z0-9\-]{1,32})\/([a-z0-9\-]{1,32})@([a-z0-9\-\._]{1,32})$
/// @dev Capture group 1 is the zone, group 2 is the agreement & 3 is the revision.
/// @dev Agreements should be referenced like within Linked Markdown like:
/// @dev   zonename/agreement@revision or just zonename/agreement to get
/// @dev the key at "latest" (an exception to the immutability
/// @dev of revisions: it can be changed to whatever)
/// @dev e.g. nation3/judge-agreement@v4.0.0 or sollee/rental@revisionhere
contract DocRegistryL2 is ERC721, IDocRegistryL2 {
    mapping(uint256 => mapping(bytes32 => mapping(bytes32 => string)))
        internal _zoneAgreements;
    mapping(bytes32 => uint256) internal _zoneHashToId;
    mapping(uint256 => string) internal _names;

    function registryType() public pure returns (uint8) {
        return 2; // L2, calldata is important
    }

    uint256 internal counter;

    constructor() ERC721("linked.md", "CONTRACTS") {}

    function claimZone(string memory zoneName) public {
        bytes32 hashed = keccak256(abi.encodePacked(zoneName));

        require(_zoneHashToId[hashed] == 0, "no minty twice");

        _mint(msg.sender, counter);
        _zoneHashToId[hashed] = counter + 1;
        _names[counter] = zoneName;
        ++counter;
    }

    function updateAgreement(
        uint256 zone,
        bytes32 key,
        string memory revisionName,
        string memory value
    ) public {
        require(ownerOf(zone) == msg.sender, "not owner");

        bytes32 revisionID = keccak256(abi.encodePacked(revisionName));

        // latest is an exception to the immutability rule
        if (revisionID != keccak256("latest")) {
            require(
                bytes(_zoneAgreements[zone][key][revisionID]).length == 0,
                "exists"
            );
        }

        _zoneAgreements[zone][key][revisionID] = value;
        emit AgreementUpdated(zone, key, value, revisionID);
    }

    function zoneAgreement(
        uint256 zone,
        bytes32 key,
        bytes32 revision
    ) public view returns (string memory) {
        return _zoneAgreements[zone][key][revision];
    }

    function zoneAgreement(
        bytes32 zone,
        bytes32 key,
        bytes32 revision
    ) public view returns (string memory) {
        return zoneAgreement(zoneID(zone), key, revision);
    }

    function name(uint256 zone) public view returns (string memory) {
        return _names[zone];
    }

    function name(bytes32 zone) public view returns (string memory) {
        return _names[zoneID(zone)];
    }

    function zoneID(bytes32 zone) public view returns (uint256) {
        return _zoneHashToId[zone] - 1;
    }

    function zoneOwner(bytes32 zone) public view returns (address) {
        return ownerOf(zoneID(zone));
    }
}
