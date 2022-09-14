// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./DataStructure/Global.sol";
import "./utils/RayMath.sol";

// todo : docs

contract RepayFacet {
    using RayMath for Ray;
    using RayMath for uint256;

    event Repay(uint256 indexed loanId);

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
            toRepay = loan.lent.mul(loan.interestPerSecond.mul(block.timestamp - loan.startDate));
            loan.assetLent.transferFrom(msg.sender, address(this), toRepay);
            loan.repaid = toRepay;
            loan.borrowerClaimed = true;
            loan.collateral.safeTransferFrom(address(this), loan.borrower, loan.tokenId);
            emit Repay(loanIds[i]);
        }
    }
}
