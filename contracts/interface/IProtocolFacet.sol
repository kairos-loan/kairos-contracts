// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "../DataStructure/Global.sol";

interface IProtocolFacet {
    function updateOffers() external returns(uint256 newNonce);
    function getRateOfTranche(uint256 id) external view returns(Ray rate);
    function getNbOfLoans() external view returns(uint256);
    function getLoan(uint256 id) external view returns(Loan memory);
    function getSupplierNonce(address supplier) external view returns(uint256);
}