// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../extensions/ERC3664TextBased.sol";

/**
 * @dev Implementation of the {ERC3664Synthetic} interface.
 */
abstract contract ERC3664Synthetic is ERC3664TextBased {
    struct SynthesizedToken {
        address owner;
        uint256 id;
    }

    // mainToken => SynthesizedToken
    mapping(uint256 => SynthesizedToken[]) public synthesizedTokens;

    // subToken => mainToken
    mapping(uint256 => uint256) public subTokens;

    // Mapping from token ID to approved another token.
    mapping(uint256 => uint256) private _combineApprovals;

    function recordSynthesized(
        address owner,
        uint256 tokenId,
        uint256 subId
    ) public {
        synthesizedTokens[tokenId].push(SynthesizedToken(owner, subId));
        subTokens[subId] = tokenId;
    }

    function getSynthesizedTokens(uint256 tokenId)
        public
        view
        returns (SynthesizedToken[] memory)
    {
        return synthesizedTokens[tokenId];
    }

    function tokenAttributes(uint256 tokenId)
        internal
        view
        returns (string memory)
    {
        bytes memory data = "";
        uint256[] memory attrs = attributesOf(tokenId);
        for (uint256 i = 0; i < attrs.length; i++) {
            if (data.length > 0) {
                data = abi.encodePacked(data, ",");
            }
            data = abi.encodePacked(
                data,
                '{"trait_type":"',
                symbol(attrs[i]),
                '","value":"',
                textOf(tokenId, attrs[i]),
                '"}'
            );
        }
        data = abi.encodePacked(data, getSubAttributes(tokenId));

        return string(data);
    }

    function getSubAttributes(uint256 tokenId)
        internal
        view
        returns (bytes memory)
    {
        bytes memory data = "";
        SynthesizedToken[] memory sTokens = synthesizedTokens[tokenId];
        for (uint256 i = 0; i < sTokens.length; i++) {
            if (data.length > 0) {
                data = abi.encodePacked(data, ",");
            }
            data = abi.encodePacked(data, tokenAttributes(sTokens[i].id));
        }
        return data;
    }
}
