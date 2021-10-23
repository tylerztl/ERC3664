// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC3664Metadata.sol";

interface IERC3664TextBased is IERC3664Metadata {
    function textOf(uint256 tokenId, uint256 attrId)
        external
        view
        returns (bytes memory);

    function attachWithText(
        uint256 tokenId,
        uint256 attrId,
        uint256 amount,
        bytes memory text
    ) external;

    function batchAttachWithTexts(
        uint256 tokenId,
        uint256[] calldata attrIds,
        uint256[] calldata amounts,
        bytes[] calldata texts
    ) external;
}
