// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./DataStructure/Global.sol";

/// @notice external loupe functions exposing protocol storage and supplier nonce incrementer
contract ProtocolFacet {
    /// @notice increment supplier nonce, effectively making all offers signed with previous nonce unusable
    /// @return newNonce value of the new supplier nonce
    function updateOffers() external returns (uint256 newNonce) {
        newNonce = ++protocolStorage().supplierNonce[msg.sender];
    }

    /// @notice gets the rate of tranche `id`
    /// @param id rate identifier
    /// @return rate the rate of the tranche, as a Ray, multiplier per second of the amount to repay (non compounding)
    ///         I.e lent * time since loan start * tranche = interests to repay
    function getRateOfTranche(uint256 id) external view returns (Ray rate) {
        return protocolStorage().tranche[id];
    }

    /// @notice gets current values of parameters impacting loans behavior and total number of loans (active and ended)
    /// @return auctionPriceFactor factor multiplied with the loan to value of a loan to get initial price
    ///         of a collateral on sale
    /// @return auctionDuration number of seconds after the auction start when the price hits 0
    /// @return nbOfLoans total number of loans ever issued (active and ended)
    function getParameters()
        external
        view
        returns (Ray auctionPriceFactor, uint256 auctionDuration, uint256 nbOfLoans)
    {
        Protocol storage proto = protocolStorage();
        auctionPriceFactor = proto.auctionPriceFactor;
        auctionDuration = proto.auctionDuration;
        nbOfLoans = proto.nbOfLoans;
    }

    /// @notice get loan metadata
    /// @param id loan identifier
    /// @return loan the corresponding loan
    function getLoan(uint256 id) external view returns (Loan memory) {
        return protocolStorage().loan[id];
    }

    /// @notice gets nonce of `supplier`
    /// @param supplier - to get nonce from
    /// @return nonce - of the supplier
    function getSupplierNonce(address supplier) external view returns (uint256) {
        return protocolStorage().supplierNonce[supplier];
    }
}
