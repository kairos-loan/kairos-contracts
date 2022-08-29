// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

error Unauthorized();

contract SupplyPosition is ERC721 {
    uint256 public totalSupply;
    address private owner;

    modifier onlyOwner() {
        if (msg.sender != owner) {revert Unauthorized();}
        _;
    }
    
    constructor() ERC721("Kairos Supply Position", "KSP") {
        owner = msg.sender;
    }

    function safeMint(address to) external onlyOwner {
        totalSupply++;
        _safeMint(to, totalSupply);
    }

    function burn(uint256 tokenId) external onlyOwner {
        _burn(tokenId);
    }
}