// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the NFT Synthetic.
 */
interface ISynthetic {
    function coreName() external view returns (string memory);

    function tokenTexts(uint256 tokenId) external view returns (string memory);

    function tokenAttributes(uint256 tokenId)
        external
        view
        returns (string memory);
}
