// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./DataStructure/Global.sol";
import "./utils/RayMath.sol";

/// @notice handles repayment with interests of loans
contract RepayFacet {
    using RayMath for Ray;
    using RayMath for uint256;

    /// @notice a loan has been repaid with interests by its borrower
    /// @param loanId loan identifier
    event Repay(uint256 indexed loanId);

    // todo : propose erc777 onReceive hook for repayment ?
    // todo : implement minimal repayment
    // todo : analysis on possible reentrency
    /// @notice repay one or multiple loans, gives collaterals back
    /// @dev repay on behalf is activated, the collateral goes to the original borrower
    /// @param loanIds identifiers of loans to repay
    function repay(uint256[] memory loanIds) external {
        Protocol storage proto = protocolStorage();
        Loan storage loan;
        uint256 lent;
        uint256 toRepay;

        for (uint8 i; i < loanIds.length; i++) {
            loan = proto.loan[loanIds[i]];
            if (loan.payment.paid > 0) {
                revert LoanAlreadyRepaid(loanIds[i]);
            }
            lent = loan.lent;
            toRepay = lent + lent.mul(loan.interestPerSecond.mul(block.timestamp - loan.startDate));
            loan.assetLent.transferFrom(msg.sender, address(this), toRepay);
            loan.payment.paid = toRepay;
            loan.payment.borrowerClaimed = true;
            loan.collateral.implem.safeTransferFrom(address(this), loan.borrower, loan.collateral.id);
            emit Repay(loanIds[i]);
        }
    }
}
