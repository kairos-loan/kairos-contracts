// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "../interface/IERC721.sol";
import "../DataStructure/Global.sol";

interface ISupplyPositionFacet is IERC721 {
    function safeMint(address, Provision calldata) external returns(uint256);
    function burn(uint256) external;
    function position(uint256) external view returns(Provision memory);
    function totalSupply() external view returns(uint256);
}