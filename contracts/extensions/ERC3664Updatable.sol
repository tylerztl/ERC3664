// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC3664Updatable.sol";
import "./ERC3664Generic.sol";

contract ERC3664Updatable is IERC3664Updatable, ERC3664Generic {
    bytes32 public constant UPDATER_ROLE = keccak256("UPDATER_ROLE");

    constructor() ERC3664Generic() {
        _setupRole(UPDATER_ROLE, _msgSender());
    }

    /**
     * @dev See {IERC3664Updatable-remove}.
     */
    function remove(uint256 tokenId, uint256 attrId) public virtual override {
        require(
            hasRole(UPDATER_ROLE, _msgSender()),
            "ERC3664Updatable: must have updater role to remove"
        );
        require(
            _attrExists(attrId),
            "ERC3664Updatable: remove for nonexistent attribute"
        );
        uint256 amount = _balances[attrId][tokenId];
        require(
            amount > 0,
            "ERC3664Updatable: token has not attached the attribute"
        );

        address operator = _msgSender();
        _beforeAttrTransfer(
            operator,
            tokenId,
            0,
            _asSingletonArray(attrId),
            _asSingletonArray(amount),
            ""
        );

        delete _balances[attrId][tokenId];
        _removeByValue(secondaryAttrs[tokenId], attrId);

        emit TransferSingle(operator, tokenId, 0, attrId, amount);
    }

    /**
     * @dev See {IERC3664Updatable-increase}.
     */
    function increase(
        uint256 tokenId,
        uint256 attrId,
        uint256 amount
    ) public virtual override {
        require(
            hasRole(UPDATER_ROLE, _msgSender()),
            "ERC3664Updatable: must have updater role to increase"
        );
        require(
            _attrExists(attrId),
            "ERC3664Updatable: increase for nonexistent attribute"
        );
        require(
            _hasAttr(tokenId, attrId),
            "ERC3664Updatable: token has not attached the attribute"
        );

        address operator = _msgSender();
        _beforeAttrTransfer(
            operator,
            0,
            tokenId,
            _asSingletonArray(attrId),
            _asSingletonArray(amount),
            ""
        );

        _balances[attrId][tokenId] += amount;

        emit TransferSingle(operator, 0, tokenId, attrId, amount);
    }

    /**
     * @dev See {IERC3664Updatable-decrease}.
     */
    function decrease(
        uint256 tokenId,
        uint256 attrId,
        uint256 amount
    ) public virtual override {
        require(
            hasRole(UPDATER_ROLE, _msgSender()),
            "ERC3664Updatable: must have updater role to decrease"
        );
        require(
            _attrExists(attrId),
            "ERC3664Updatable: decrease for nonexistent attribute"
        );
        require(
            _hasAttr(tokenId, attrId),
            "ERC3664Updatable: token has not attached the attribute"
        );

        address operator = _msgSender();
        _beforeAttrTransfer(
            operator,
            tokenId,
            0,
            _asSingletonArray(attrId),
            _asSingletonArray(amount),
            ""
        );

        uint256 tb = _balances[attrId][tokenId];
        require(tb >= amount);
        _balances[attrId][tokenId] = tb - amount;

        emit TransferSingle(operator, tokenId, 0, attrId, amount);
    }
}
