// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "./DataStructure/Global.sol";
import "./utils/RayMath.sol";

contract ClaimFacet {
    using RayMath for Ray;
    using RayMath for uint256;

    event Claim(address indexed claimed, uint256 indexed amount, uint256 indexed positionId);

    function claim(uint256[] calldata positionIds) external {
        for (uint8 i; i < positionIds.length; i++) {
            
        }
    }

    function claimAsBorrower(uint256[] calldata loanIds) external {

    }
}