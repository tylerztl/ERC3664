// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC3664Metadata.sol";

interface IERC3664Upgradable is IERC3664Metadata {
    event AttributeUpgraded(
        uint256 indexed tokenId,
        uint256 indexed attrId,
        uint8 level
    );

    function levelOf(uint256 tokenId, uint256 attrId)
        external
        view
        returns (uint8);

    function mintWithLevel(
        uint256 attrId,
        string memory name,
        string memory symbol,
        string memory uri,
        uint8 maxLevel
    ) external;

    function upgrade(
        uint256 tokenId,
        uint256 attrId,
        uint8 level
    ) external;
}
