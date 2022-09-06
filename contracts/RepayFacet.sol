// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "./DataStructure/Global.sol";

// todo : docs

contract RepayFacet {
    // todo : implement minimal repayment
    // todo : analysis on possible reentrency
    // repay on behalf is activated, the collateral goes to the original borrower
    function repay(uint256[] memory loanIds) external {
        Protocol storage proto = protocolStorage();
        Loan storage loan;
        uint256 toRepay;

        for(uint8 i; i < loanIds.length; i++){
            loan = proto.loan[loanIds[i]];
            if (loan.repaid > 0) { revert LoanAlreadyRepaid(loanIds[i]); }
            toRepay = (block.timestamp - loan.startDate) * loan.interestPerSecond;
            loan.assetLent.transferFrom(msg.sender, address(this), toRepay);
            loan.repaid = toRepay;
            loan.collateral.safeTransferFrom(address(this), msg.sender, loan.tokenId);
        }
    }
}