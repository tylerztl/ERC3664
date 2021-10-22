// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC3664Upgradable.sol";
import "./ERC3664Generic.sol";

contract ERC3664Upgradable is ERC3664Generic, IERC3664Upgradable {
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    // attribute ID => settings
    mapping(uint256 => uint8) public settings;

    // attribute ID => token ID => current Level
    mapping(uint256 => mapping(uint256 => uint8)) private _levels;

    constructor() ERC3664Generic() {
        _setupRole(UPGRADER_ROLE, _msgSender());
    }

    function levelOf(uint256 _tokenId, uint256 _attrId)
        public
        view
        virtual
        override
        returns (uint8)
    {
        return _levels[_attrId][_tokenId];
    }

    function mintWithLevel(
        uint256 attrId,
        string memory name,
        string memory symbol,
        string memory uri,
        uint8 maxLevel
    ) public virtual override {
        super.mint(attrId, name, symbol, uri);

        settings[attrId] = maxLevel;
    }

    function upgrade(
        uint256 _tokenId,
        uint256 _attrId,
        uint8 _level
    ) public virtual override {
        require(
            hasRole(UPGRADER_ROLE, _msgSender()),
            "ERC3664Upgradable: must have evolutiver role to evolutive"
        );
        require(
            _hasAttr(_tokenId, _attrId),
            "ERC3664Upgradable: token has not attached the attribute"
        );
        require(
            _level <= settings[_attrId],
            "ERC3664Upgradable: exceeded the maximum level"
        );
        require(
            _level == _levels[_attrId][_tokenId] + 1,
            "ERC3664Upgradable: invalid level"
        );

        _levels[_attrId][_tokenId] = _level;

        emit AttributeUpgraded(_tokenId, _attrId, _level);
    }
}
