// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC3664Transferable.sol";
import "./ERC3664Generic.sol";
import "../../utils/ITokenHolder.sol";

/**
 * @dev Implementation of the {ERC3664Transferable} interface.
 */
contract ERC3664Transferable is IERC3664Transferable, ERC3664Generic {
    bytes32 public constant TRANSFER_ROLE = keccak256("TRANSFER_ROLE");

    // attribute ID => from token ID => to token ID
    mapping(uint256 => mapping(uint256 => uint256)) private _allowances;

    address private _nft;

    modifier onlyHolder(uint256 tokenId) {
        require(
            ITokenHolder(_nft).holderOf(tokenId) == _msgSender(),
            "ERC3664Transferable: caller is not the nft holder"
        );
        _;
    }

    constructor(address nft) ERC3664Generic() {
        _nft = nft;

        _setupRole(TRANSFER_ROLE, _msgSender());
    }

    /**
     * @dev See {IERC3664Transferable-isApproved}.
     */
    function isApproved(
        uint256 from,
        uint256 to,
        uint256 attrId
    ) public view virtual override returns (bool) {
        return _allowances[attrId][from] == to;
    }

    /**
     * @dev See {IERC3664Transferable-approve}.
     */
    function approve(
        uint256 from,
        uint256 to,
        uint256 attrId
    ) public virtual override onlyHolder(from) {
        require(
            from != 0,
            "ERC3664Transferable: approve from the zero address"
        );
        require(to != 0, "ERC3664Transferable: approve to the zero address");
        require(
            !_hasAttr(to, attrId),
            "ERC3664Transferable: recipient token has already attached the attribute"
        );

        _allowances[attrId][from] = to;

        emit AttributeApproval(_msgSender(), from, to, attrId);
    }

    /**
     * @dev See {IERC3664Transferable-transferFrom}.
     */
    function transferFrom(
        uint256 from,
        uint256 to,
        uint256 attrId
    ) public virtual override {
        address operator = _msgSender();
        require(
            ITokenHolder(_nft).holderOf(from) == operator ||
                hasRole(TRANSFER_ROLE, operator),
            "ERC3664Transferable: caller no transfer access"
        );
        require(
            isApproved(from, to, attrId),
            "ERC3664Transferable: nft holder not approve the attribute to recipient"
        );
        require(
            !_hasAttr(to, attrId),
            "ERC3664Transferable: recipient has attached the attribute"
        );

        uint256 amount = _balances[attrId][from];
        _beforeAttrTransfer(
            operator,
            from,
            to,
            _asSingletonArray(attrId),
            _asSingletonArray(amount),
            ""
        );

        _balances[attrId][to] = amount;
        delete _balances[attrId][from];
        delete _allowances[attrId][from];

        emit TransferSingle(operator, from, to, attrId, amount);
    }
}
