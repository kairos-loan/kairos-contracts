// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {BigKairos} from "./BigKairos.sol";
import {Loan, Provision} from "../../src/DataStructure/Storage.sol";
import {protocolStorage, supplyPositionStorage} from "../../src/DataStructure/Global.sol";

/// @notice Delegate Call Target for modifying kairos internal state
contract DCTarget is BigKairos {
    function storeProvision(Provision memory provision, uint256 positionId) external {
        supplyPositionStorage().provision[positionId] = provision;
    }

    function mintPosition(address to, Provision memory provision) external returns (uint256 tokenId) {
        tokenId = safeMint(to, provision);
    }

    /// @notice stores a new loan with a new id and emit a borrow event
    function mintLoan(Loan memory loan) external returns (uint256 loanId) {
        loanId = ++protocolStorage().nbOfLoans;
        emit Borrow(loanId, abi.encode(loan));
        storeLoan(loan, loanId);
    }

    function storeLoan(Loan memory loan, uint256 loanId) public {
        protocolStorage().loan[loanId] = loan;
    }
}
