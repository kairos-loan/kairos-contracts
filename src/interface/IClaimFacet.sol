// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

interface IClaimFacet {
    function claim(uint256[] calldata positionIds) external returns (uint256 sent);

    function claimAsBorrower(uint256[] calldata loanIds) external returns (uint256 sent);
}
