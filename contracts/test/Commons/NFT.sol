// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721 {
    uint256 public totalSupply;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function mintOneTo(address to) public returns (uint256) {
        totalSupply++;
        _mint(to, totalSupply);
        return totalSupply;
    }

    function mintOne() public returns (uint256) {
        totalSupply++;
        _safeMint(msg.sender, totalSupply);
        return totalSupply;
    }
}
