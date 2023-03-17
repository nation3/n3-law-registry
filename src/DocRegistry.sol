// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IDocRegistry.sol";

/// @title Linked Markdown Agreement Registry
/// @author sollee.eth
/// @notice Package manager for Linked Markdown
/// @dev Zone names MUST satisfy the following regex:
/// @dev   ^([a-zA-Z0-9\-]{1,32})$
/// @dev Agreement names MUST satisfy the following regex:
/// @dev   ^([a-z0-9\-]{1,32})$
/// @dev Agreements should be referenced like within Linked Markdown like:
/// @dev   zonename/agreement@revision or just zonename/agreement for latest
/// @dev e.g. Nation3/judge-agreement@4
contract DocRegistry is ERC721, IDocRegistry, Ownable {
    mapping(bytes32 => mapping(bytes32 => Multihash[]))
        internal _zoneAgreements;
    mapping(bytes32 => string) internal _names;

    error GlobalPaused();
    error ZonePaused();
    error KeyPaused();

    bool public zoneClaimsPaused;
    bool public agreementUpdatesPaused;

    mapping(bytes32 => bool) public zoneUpdatesPaused;
    mapping(bytes32 => mapping(bytes32 => bool)) public keyUpdatesPaused;

    event ZoneClaimsPaused(bool pause);
    event UpdatesPaused(bool pause);
    event UpdatesPaused(bytes32 zone, bool pause);
    event UpdatesPaused(bytes32 zone, bytes32 key, bool pause);

    constructor() ERC721("linked.md", "CONTRACTS") {}

    function claimZone(string memory zoneName) public {
        if (zoneClaimsPaused) revert GlobalPaused();
        bytes32 _hash = keccak256(abi.encodePacked(zoneName));

        _mint(msg.sender, uint256(_hash));
        _names[_hash] = zoneName;
    }

    function updateAgreement(
        bytes32 zone,
        bytes32 key,
        Multihash calldata value
    ) public {
        if (ownerOf(uint256(zone)) != msg.sender) revert Unauthorized();
        if (agreementUpdatesPaused) revert GlobalPaused();
        if (zoneUpdatesPaused[zone]) revert ZonePaused();
        if (keyUpdatesPaused[zone][key]) revert KeyPaused();

        _zoneAgreements[zone][key].push(value);
        emit AgreementUpdated(
            zone,
            key,
            value.hash, //
            latestAgreement(zone, key)
        );
    }

    function zoneAgreement(
        bytes32 zone,
        bytes32 key,
        uint256 version
    ) public view returns (Multihash memory) {
        return _zoneAgreements[zone][key][version];
    }

    function latestAgreement(bytes32 zone, bytes32 key)
        public
        view
        returns (uint256)
    {
        return _zoneAgreements[zone][key].length - 1;
    }

    function name(bytes32 zone) public view returns (string memory) {
        return _names[zone];
    }

    function zoneID(bytes32 zone) external pure returns (uint256) {
        return uint256(zone);
    }

    function zoneOwner(bytes32 zone) external view returns (address) {
        return ownerOf(uint256(zone));
    }

    /// @notice Take the zone from its owner
    /// @notice Useful for stopping phishing.
    /// @param zone Hash of zone name (e.g. sollee, luisc, nation3).
    function reclaimZone(bytes32 zone) external onlyOwner {
        _transfer(ownerOf(uint256(zone)), msg.sender, uint256(zone));
    }

    /// @notice Pause/unpause claiming new zones. Owner only.
    function pauseZoneClaims() external onlyOwner {
        zoneClaimsPaused = !zoneClaimsPaused;
        emit ZoneClaimsPaused(zoneClaimsPaused);
    }

    /// @notice Pause/unpause updating agreements. Owner only.
    function pauseAgreementUpdates() external onlyOwner {
        agreementUpdatesPaused = !agreementUpdatesPaused;
        emit UpdatesPaused(agreementUpdatesPaused);
    }

    /// @notice Pause/unpause updating agreements. Owner only.
    function pauseAgreementUpdates(bytes32 zone) external onlyOwner {
        zoneUpdatesPaused[zone] = !zoneUpdatesPaused[zone];
        emit UpdatesPaused(zone, agreementUpdatesPaused);
    }

    /// @notice Pause/unpause updating agreements. Owner only.
    function pauseAgreementUpdates(bytes32 zone, bytes32 key)
        external
        onlyOwner
    {
        keyUpdatesPaused[zone][key] = !keyUpdatesPaused[zone][key];
        emit UpdatesPaused(zone, key, agreementUpdatesPaused);
    }
}
