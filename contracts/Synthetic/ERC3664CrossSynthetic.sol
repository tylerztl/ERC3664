// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../extensions/ERC3664TextBased.sol";

/**
 * @dev Implementation of the {ERC3664CrossSynthetic} interface.
 */
abstract contract ERC3664CrossSynthetic is ERC3664TextBased {
    struct SynthesizedToken {
        address token;
        address owner;
        uint256 id;
    }

    // mainToken => SynthesizedToken
    mapping(uint256 => SynthesizedToken[]) public synthesizedTokens;

    function getSynthesizedTokens(uint256 tokenId)
        public
        view
        returns (SynthesizedToken[] memory)
    {
        return synthesizedTokens[tokenId];
    }

    function tokenAttributes(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        bytes memory data = "";
        uint256 id = primaryAttributeOf(tokenId);
        if (id > 0) {
            data = abi.encodePacked(
                '{"trait_type":"',
                symbol(id),
                '","value":"',
                textOf(tokenId, id),
                '"}'
            );
        }
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
        public
        view
        returns (bytes memory)
    {
        bytes memory data = "";
        SynthesizedToken[] storage sTokens = synthesizedTokens[tokenId];
        for (uint256 i = 0; i < sTokens.length; i++) {
            if (data.length > 0) {
                data = abi.encodePacked(data, ",");
            }
            data = abi.encodePacked(data, tokenAttributes(sTokens[i].id));
        }
        return data;
    }
}
