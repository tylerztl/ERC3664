// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ITokenHolder {
    /**
     * @dev Returns the holder of token type `id`.
     */
    function holderOf(uint256 id) external view returns (address);
}
