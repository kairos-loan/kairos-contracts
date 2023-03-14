// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {DiamondERC721} from "../../src/SupplyPositionLogic/DiamondERC721.sol";

contract MockERC721 is DiamondERC721 {
    function mint(address to, uint256 tokenId) public virtual {
        _mint(to, tokenId);
    }

    function burn(uint256 tokenId) public virtual {
        _burn(tokenId);
    }

    function safeMint(address to, uint256 tokenId) public virtual {
        _safeMint(to, tokenId);
    }

    function safeMint(address to, uint256 tokenId, bytes memory data) public virtual {
        _safeMint(to, tokenId, data);
    }
}
