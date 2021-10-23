// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERC3664.sol";
import "./IERC3664Evolvable.sol";

abstract contract ERC3664Evolvable is ERC3664, IERC3664Evolvable {
    struct EvolutiveSettings {
        // Probability in basis points (out of 100) of receiving each level (descending)
        uint8[] probabilities;
        // Block interval required for evolutive
        uint256[] evolutiveIntervals;
    }

    struct EvolutiveState {
        uint8 curLevel;
        uint256 birthBlock;
        uint256 nextEvolutiveBlock;
        // normal or broken
        bool status;
    }

    // attribute ID => evolutive settings
    mapping(uint256 => EvolutiveSettings) private _settings;

    // attribute ID => token ID => evolutive state
    mapping(uint256 => mapping(uint256 => EvolutiveState)) private _states;

    function period(uint256 tokenId, uint256 attrId)
        public
        view
        override
        returns (uint256)
    {
        if (_states[attrId][tokenId].nextEvolutiveBlock > block.number) {
            return _states[attrId][tokenId].nextEvolutiveBlock - block.number;
        }
        return 0;
    }

    function mintWith(
        uint256 attrId,
        string memory name,
        string memory symbol,
        string memory uri,
        uint8[] memory probabilities,
        uint256[] memory evolutiveIntervals
    ) public {
        require(
            probabilities.length == evolutiveIntervals.length,
            "ERC3664Evolvable: probabilities and evolutiveIntervals length mismatch"
        );

        super._mint(attrId, name, symbol, uri);

        _settings[attrId] = EvolutiveSettings(
            probabilities,
            evolutiveIntervals
        );
    }

    function attach(
        uint256 tokenId,
        uint256 attrId,
        uint256 amount
    ) public virtual override(ERC3664, IERC3664) {
        super.attach(tokenId, attrId, amount);

        _states[attrId][tokenId] = EvolutiveState(
            1,
            block.number,
            block.number + _settings[attrId].evolutiveIntervals[0],
            true
        );
    }

    function evolutive(uint256 tokenId, uint256 attrId)
        public
        virtual
        override
    {
        require(
            _hasAttr(tokenId, attrId),
            "ERC3664Evolvable: token has not attached the attribute"
        );
        require(
            _states[attrId][tokenId].status,
            "ERC3664Evolvable: token has broken"
        );
        uint8 curLv = _states[attrId][tokenId].curLevel;
        require(
            curLv <= _settings[attrId].probabilities.length,
            "ERC3664Evolvable: exceeded the maximum level"
        );
        require(
            block.number >= _states[attrId][tokenId].nextEvolutiveBlock,
            "EvolvableAttribute: did not reach evolution time"
        );

        // random evolutive
        EvolutiveState storage s = _states[attrId][tokenId];
        uint256 n = _seed(_msgSender(), 100);
        if (n <= _settings[attrId].probabilities[curLv - 1]) {
            // succeed
            s.curLevel += 1;
            s.nextEvolutiveBlock = _settings[attrId].probabilities[curLv];
        } else {
            // failed
            s.status = false;
        }

        emit AttributeEvolvable(_msgSender(), tokenId, attrId, s.status);
    }

    function repair(uint256 tokenId, uint256 attrId) public virtual override {
        require(
            _hasAttr(tokenId, attrId),
            "ERC3664Evolvable: token has not attached the attribute"
        );
        require(
            !_states[attrId][tokenId].status,
            "ERC3664Evolvable: token is normal"
        );

        EvolutiveState storage s = _states[attrId][tokenId];
        s.status = true;
        s.nextEvolutiveBlock =
            block.number +
            _settings[attrId].evolutiveIntervals[s.curLevel - 1];

        emit AttributeRepaired(_msgSender(), tokenId, attrId);
    }

    function _seed(address _user, uint256 _supply)
        internal
        view
        returns (uint256)
    {
        return
            uint256(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            _user,
                            block.number,
                            block.timestamp,
                            block.difficulty
                        )
                    )
                ) % _supply
            );
    }
}
