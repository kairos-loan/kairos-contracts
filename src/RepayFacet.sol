// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IRepayFacet} from "./interface/IRepayFacet.sol";

import {Loan, Protocol} from "./DataStructure/Storage.sol";
import {LoanAlreadyRepaid} from "./DataStructure/Errors.sol";
import {protocolStorage} from "./DataStructure/Global.sol";
import {Ray} from "./DataStructure/Objects.sol";
import {RayMath} from "./utils/RayMath.sol";
import {Erc20CheckedTransfer} from "./utils/Erc20CheckedTransfer.sol";

/// @notice handles repayment with interests of loans
contract RepayFacet is IRepayFacet {
    using RayMath for Ray;
    using RayMath for uint256;
    using Erc20CheckedTransfer for IERC20;

    /// @notice repay one or multiple loans, gives collaterals back
    /// @dev repay on behalf is activated, the collateral goes to the original borrower
    /// @param loanIds identifiers of loans to repay
    function repay(uint256[] memory loanIds) external {
        Protocol storage proto = protocolStorage();
        Loan storage loan;
        uint256 lent;
        uint256 toRepay;

        for (uint256 i = 0; i < loanIds.length; i++) {
            loan = proto.loan[loanIds[i]];
            if (loan.payment.paid > 0 || loan.payment.borrowerClaimed || loan.payment.liquidated) {
                revert LoanAlreadyRepaid(loanIds[i]);
            }
            lent = loan.lent;
            /* during the toRepay calculus, we can consider that (block.timestamp - loan.startDate)
            won't exceed 1e10 (>100 years) and interest per second (unwrapped value) won't exceed
            1e27 (corresponding to an amount to repay doubling after 1 second), we can deduce that
            (loan.interestPerSecond.mul(block.timestamp - loan.startDate)) is capped by 1e10 * 1e27 = 1e37
            we want to avoid the toRepay calculus to overflow so the result must not exceed 1e77
            as (1e77 < type(uint256).max). So we can allow lent to go as high as 1e40, but not above.
            This explains why borrowing throws on loan.lent > 1e40, as this realisticly avoids
            repaying being impossible due to an overflow. */
            toRepay = lent + lent.mul(loan.interestPerSecond.mul(block.timestamp - loan.startDate));
            loan.payment.paid = toRepay;
            loan.payment.borrowerClaimed = true;
            loan.assetLent.checkedTransferFrom(msg.sender, address(this), toRepay);
            loan.collateral.implem.safeTransferFrom(address(this), loan.borrower, loan.collateral.id);
            emit Repay(loanIds[i]);
        }
    }
}
