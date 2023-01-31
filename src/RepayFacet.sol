// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {IRepayFacet} from "../interface/IRepayFacet.sol";
import {Loan, Protocol} from "./DataStructure/Storage.sol";
import {ERC20TransferFailed, LoanAlreadyRepaid} from "./DataStructure/Errors.sol";
import {protocolStorage} from "./DataStructure/Global.sol";
import {Ray} from "./DataStructure/Objects.sol";
import {RayMath} from "./utils/RayMath.sol";

/// @notice handles repayment with interests of loans
contract RepayFacet is IRepayFacet {
    using RayMath for Ray;
    using RayMath for uint256;

    /// @notice a loan has been repaid with interests by its borrower
    /// @param loanId loan identifier
    event Repay(uint256 indexed loanId);

    // todo #17 : propose erc777 onReceive hook for repayment ?
    // todo #16 : implement minimal repayment
    // todo #15 : analysis on possible reentrency
    /// @notice repay one or multiple loans, gives collaterals back
    /// @dev repay on behalf is activated, the collateral goes to the original borrower
    /// @param loanIds identifiers of loans to repay
    function repay(uint256[] memory loanIds) external {
        Protocol storage proto = protocolStorage();
        Loan storage loan;
        uint256 lent;
        uint256 toRepay;

        for (uint8 i = 0; i < loanIds.length; i++) {
            loan = proto.loan[loanIds[i]];
            if (loan.payment.paid > 0) {
                revert LoanAlreadyRepaid(loanIds[i]);
            }
            lent = loan.lent;
            toRepay = lent + lent.mul(loan.interestPerSecond.mul(block.timestamp - loan.startDate));
            if (!loan.assetLent.transferFrom(msg.sender, address(this), toRepay)) {
                revert ERC20TransferFailed(loan.assetLent, msg.sender, address(this));
            }
            loan.payment.paid = toRepay;
            loan.payment.borrowerClaimed = true;
            loan.collateral.implem.safeTransferFrom(address(this), loan.borrower, loan.collateral.id);
            emit Repay(loanIds[i]);
        }
    }
}
