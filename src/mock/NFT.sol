// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {ERC721, ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract NFT is ERC721Enumerable {
    error MaxSupplyReached();

    string internal baseURI;

    /* solhint-disable-next-line no-empty-blocks */
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        baseURI = "ipfs://QmPMc4tcBsMqLRuCQtPmPe84bpSjrC3Ky7t3JWuHXYB4aS/"; // default: doodles metadata
    }

    function mintOneTo(address to) public returns (uint256 createdId) {
        checkMaxSupplyOnIncrement();
        createdId = totalSupply() + 1;
        _mint(to, createdId);
    }

    function mintOne() public returns (uint256 createdId) {
        checkMaxSupplyOnIncrement();
        createdId = totalSupply() + 1;
        _safeMint(msg.sender, createdId);
    }

    function mintMultiple(uint256 amount) public {
        for (uint256 i = 0; i < amount; i++) {
            mintOne();
        }
    }

    function setBaseURI(string memory newBaseURI) public {
        baseURI = newBaseURI;
    }

    function checkMaxSupplyOnIncrement() internal {
        if (totalSupply() >= 10_000) {
            revert MaxSupplyReached();
        }
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }
}
