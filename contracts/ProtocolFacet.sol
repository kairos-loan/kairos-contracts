// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "./DataStructure/Global.sol";

contract ProtocolFacet {
    function updateOffers() external returns(uint256 newNonce) {
        newNonce = ++protocolStorage().supplierNonce[msg.sender];
    }

    function getRateOfTranche(uint256 id) external view returns(Ray rate){
        return protocolStorage().tranche[id];
    }

    function getNbOfLoans() external view returns(uint256){
        return protocolStorage().nbOfLoans;
    }

    function getLoan(uint256 id) external view returns(Loan memory){
        return protocolStorage().loan[id];
    }

    function getSupplierNonce(address supplier) external view returns(uint256) {
        return protocolStorage().supplierNonce[supplier];
    }
}