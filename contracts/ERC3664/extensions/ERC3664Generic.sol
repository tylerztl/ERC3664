// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/utils/Context.sol";
import "openzeppelin-solidity/contracts/access/AccessControlEnumerable.sol";
import "../ERC3664.sol";

contract ERC3664Generic is Context, AccessControlEnumerable, ERC3664 {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant ATTACH_ROLE = keccak256("ATTACH_ROLE");

    constructor() ERC3664() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(ATTACH_ROLE, _msgSender());
    }

    /**
     * @dev Mint new attribute type with metadata.
     *
     * See {ERC3664-_mint}.
     */
    function mint(
        uint256 attrId,
        string memory _name,
        string memory _symbol,
        string memory _uri
    ) public virtual {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "ERC3664Generic: must have minter role to mint"
        );

        _mint(attrId, _name, _symbol, _uri);
    }

    /**
     * @dev [Batched] version of {mint}.
     */
    function mintBatch(
        uint256[] calldata attrIds,
        string[] calldata names,
        string[] calldata symbols,
        string[] calldata uris
    ) public virtual {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "ERC3664Generic: must have minter role to mint"
        );

        _mintBatch(attrIds, names, symbols, uris);
    }

    /**
     * @dev See {ERC3664-attach}.
     */
    function attach(
        uint256 tokenId,
        uint256 attrId,
        uint256 amount,
        bytes memory text,
        bool isPrimary
    ) public virtual override {
        require(
            hasRole(ATTACH_ROLE, _msgSender()),
            "ERC3664Generic: must have attach role to attach"
        );

        super.attach(tokenId, attrId, amount, text, isPrimary);
    }

    /**
     * @dev See {ERC3664-batchAttach}.
     */
    function batchAttach(
        uint256 tokenId,
        uint256[] calldata attrIds,
        uint256[] calldata amounts,
        bytes[] calldata texts
    ) public virtual override {
        require(
            hasRole(ATTACH_ROLE, _msgSender()),
            "ERC3664Generic: must have attach role to attach"
        );

        super.batchAttach(tokenId, attrIds, amounts, texts);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlEnumerable, ERC3664)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
