// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./BigKairos.sol";

/// @notice Delegate Call Target for modifying kairos internal state
contract DCTarget is BigKairos {
    function storeLoan(Loan memory loan, uint256 loanId) external {
        protocolStorage().loan[loanId] = loan;
    }

    function storeProvision(Provision memory provision, uint256 positionId) external {
        supplyPositionStorage().provision[positionId] = provision;
    }

    function mintPosition(address to, Provision memory provision) external returns (uint256 tokenId) {
        tokenId = safeMint(to, provision);
    }
}
