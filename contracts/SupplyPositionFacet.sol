// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./SupplyPositionLogic/DiamondERC721.sol";

/// @notice NFT collection facet for transferable tradable non fungible supply positions
contract SupplyPositionFacet is DiamondERC721 {

    // constructor equivalent is in the Initializer contract

    /// @notice get metadata on provision linked to the supply position
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