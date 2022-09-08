// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "./utils/DiamondERC721.sol";

/// @notice NFT collection facet for transferable tradable non fungible supply positions
contract SupplyPositionFacet is DiamondERC721 {

    // constructor equivalent is in the Initializer contract

    modifier onlySelf() {
        if(msg.sender != address(this)) { revert Unauthorized(); }
        _;
    }

    function safeMint(address to, Provision calldata provision) external onlySelf returns(uint256 tokenId) {
        SupplyPosition storage sp = supplyPositionStorage();

        tokenId = ++sp.totalSupply;
        sp.provision[tokenId] = provision;
        _safeMint(to, tokenId);
    }

    function burn(uint256 tokenId) external onlySelf {
        _burn(tokenId);
    }

    function position(uint256 tokenId) external view returns(Provision memory) {
        SupplyPosition storage sp = supplyPositionStorage();

        if(tokenId > sp.totalSupply) { revert ERC721InvalidTokenId(); }

        return sp.provision[tokenId];
    }

    /// @notice total number of supply positions ever minted (counting burned ones)
    function totalSupply() external view returns(uint256) {
        return supplyPositionStorage().totalSupply;
    }
}