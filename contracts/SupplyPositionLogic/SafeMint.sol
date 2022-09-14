// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./NFTUtils.sol";

contract SafeMint is NFTUtils {
    function safeMint(address to, Provision memory provision) internal returns(uint256 tokenId) {
        SupplyPosition storage sp = supplyPositionStorage();

        tokenId = ++sp.totalSupply;
        sp.provision[tokenId] = provision;
        _safeMint(to, tokenId);
    }
}