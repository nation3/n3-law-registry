// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// @title Linked Markdown Agreement Registry Interface
/// @author sollee.eth
/// @notice Package manager for Linked Markdown
/// @dev Zone names MUST satisfy the following regex:
/// @dev   ^([a-zA-Z0-9\-]{1,32})$
/// @dev Agreement names MUST satisfy the following regex:
/// @dev   ^([a-z0-9\-]{1,32})$
/// @dev Agreements should be referenced like within Linked Markdown like:
/// @dev   zonename/agreement@revision or just zonename/agreement to get
/// @dev the key at "latest" (an exception to the "set once" rule
/// @dev of revisions: it can be changed to whatever)
/// @dev e.g. Nation3/judge-agreement@v4.0.0
interface IDocRegistry {
    error Unauthorized();

    event AgreementUpdated(
        bytes32 zone,
        bytes32 key,
        bytes32 value,
        bytes32 revision
    );

    /// @notice Claim a zone
    /// NOTE: Zone names SHOULD satisfy the following regex:
    /// ^([a-zA-Z0-9\-]{1,32})$
    /// Otherwise, it cannot be resolved.
    /// @param zone Zone name.
    function claimZone(string memory zone) external;

    /// @notice Update/create an agreement under a zone, creating a new revision
    /// @dev Agreements have tags so that people can choose to
    /// @dev lock on to one revision or automatically use the latest.
    /// NOTE: Agreement names SHOULD satisfy the following regex:
    /// ^([a-z0-9\-]{1,32})$
    /// @param zone NFT ID of zone name (e.g. vitalik, luisc, nation3)
    /// @param key Hash of agreement name (e.g. rental, delivery-escrow)
    /// @param revision Hash of revision name (e.g. v1.0.0)
    /// @param value CID of agreement data, to be retrieved via IPFS
    /// @param cidType Hash function & size, for IPFS forward compatibility
    function updateAgreement(
        bytes32 zone,
        bytes32 key,
        string memory revision,
        bytes32 value,
        uint8 cidType
    ) external;

    /// @notice Returns CID of an agreement version
    /// @param zone Hash of zone name (e.g. sollee, luisc, nation3).
    /// @param key Hash of agreement name (e.g. rental, delivery-escrow).
    /// @param revision Revision of agreement
    /// @return CID of agreement data, to be retrieved via IPFS
    function zoneAgreement(
        bytes32 zone,
        bytes32 key,
        bytes32 revision
    ) external view returns (bytes32);

    /// @notice Returns zone owner
    /// @param zone Hash of zone name (e.g. sollee, luisc, nation3).
    /// @return Zone owner
    function zoneOwner(bytes32 zone) external view returns (address);

    /// @notice Returns the token ID of a zone
    /// @param zone Hash of zone name (e.g. sollee, luisc, nation3).
    /// @return Token ID
    function zoneID(bytes32 zone) external view returns (uint256);

    /// @notice Returns the name of a zone
    /// @param zone Hash of zone name (e.g. sollee, luisc, nation3).
    /// @return Zone name
    function name(bytes32 zone) external view returns (string memory);
}
