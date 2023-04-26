// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IDocRegistry.sol";

/// @title Linked Markdown Agreement Registry
/// @author sollee.eth
/// @notice Package manager for Linked Markdown
/// @dev Zone names MUST satisfy the following regex:
/// @dev   ^([a-z0-9\-]{1,32})$
/// @dev Agreement names MUST satisfy the following regex:
/// @dev   ^([a-z0-9\-]{1,32})$
/// @dev Agreements should be referenced like within Linked Markdown like:
/// @dev   zonename/agreement@revision or just zonename/agreement to get
/// @dev the key at "latest" (an exception to the immutability
/// @dev of revisions: it can be changed to whatever)
/// @dev e.g. nation3/judge-agreement@v4.0.0 or sollee/rental@revisionhere
contract DocRegistry is ERC721, IDocRegistry {
    mapping(bytes32 => mapping(bytes32 => mapping(bytes32 => bytes)))
        internal _zoneAgreements;
    mapping(bytes32 => string) internal _names;

    function registryType() public pure returns (uint8) {
        return 1; // L1, calldata is not important
    }

    constructor() ERC721("linked.md", "CONTRACTS") {}

    function claimZone(string memory zoneName) public {
        bytes32 _hash = keccak256(abi.encodePacked(zoneName));

        _mint(msg.sender, uint256(_hash));
        _names[_hash] = zoneName;
    }

    function updateAgreement(
        bytes32 zone,
        bytes32 key,
        string calldata revisionName,
        bytes calldata value
    ) public {
        if (ownerOf(uint256(zone)) != msg.sender) revert Unauthorized();

        bytes32 revisionID = keccak256(bytes(revisionName));

        // latest is an exception to the immutability rule
        if (revisionID != keccak256("latest")) {
            require(
                _zoneAgreements[zone][key][revisionID].length == 0,
                "exists"
            );
        }

        _zoneAgreements[zone][key][revisionID] = value;
        emit AgreementUpdated(zone, key, value, revisionID);
    }

    function zoneAgreement(
        bytes32 zone,
        bytes32 key,
        bytes32 revision
    ) public view returns (bytes memory) {
        return _zoneAgreements[zone][key][revision];
    }

    function name(bytes32 zone) public view returns (string memory) {
        return _names[zone];
    }

    function zoneID(bytes32 zone) public pure returns (uint256) {
        return uint256(zone);
    }

    function zoneOwner(bytes32 zone) public view returns (address) {
        return ownerOf(uint256(zone));
    }
}
