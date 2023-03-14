// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IClaimFacet} from "./interface/IClaimFacet.sol";
import {BorrowerAlreadyClaimed, LoanNotRepaidOrLiquidatedYet, NotBorrowerOfTheLoan} from "./DataStructure/Errors.sol";
import {ERC721CallerIsNotOwnerNorApproved} from "./DataStructure/ERC721Errors.sol";
import {Loan, Protocol, Provision, SupplyPosition} from "./DataStructure/Storage.sol";
import {ONE, protocolStorage, supplyPositionStorage} from "./DataStructure/Global.sol";
import {Ray} from "./DataStructure/Objects.sol";
import {RayMath} from "./utils/RayMath.sol";
import {Erc20CheckedTransfer} from "./utils/Erc20CheckedTransfer.sol";
import {SafeMint} from "./SupplyPositionLogic/SafeMint.sol";

/// @notice claims supplier and borrower rights on loans or supply positions
contract ClaimFacet is IClaimFacet, SafeMint {
    using RayMath for Ray;
    using RayMath for uint256;
    using Erc20CheckedTransfer for IERC20;

    /// @notice claims principal plus interests or liquidation share due as a supplier
    /// @param positionIds identifiers of one or multiple supply position to burn
    /// @return sent amount sent
    function claim(uint256[] calldata positionIds) external returns (uint256 sent) {
        Protocol storage proto = protocolStorage();
        SupplyPosition storage sp = supplyPositionStorage();
        Loan storage loan;
        Provision storage provision;
        uint256 loanId;
        uint256 sentTemp;

        for (uint256 i = 0; i < positionIds.length; i++) {
            if (!_isApprovedOrOwner(msg.sender, positionIds[i])) {
                revert ERC721CallerIsNotOwnerNorApproved();
            }
            _burn(positionIds[i]);
            provision = sp.provision[positionIds[i]];
            loanId = provision.loanId;
            loan = proto.loan[loanId];
            if (loan.payment.paid < loan.lent && !loan.payment.liquidated) {
                revert LoanNotRepaidOrLiquidatedYet(loanId);
            }
            sentTemp = loan.payment.liquidated
                ? sendShareOfSaleAsSupplier(loan, provision)
                : sendInterests(loan, provision);
            emit Claim(msg.sender, sentTemp, loanId);
            sent += sentTemp;
        }
    }

    /// @notice claims share of liquidation due to a borrower who's collateral has been sold
    /// @param loanIds loan identifiers of one or multiple loans where the borrower wants to claim liquidation share
    /// @return sent amount sent
    function claimAsBorrower(uint256[] calldata loanIds) external returns (uint256 sent) {
        Protocol storage proto = protocolStorage();
        Loan storage loan;
        uint256 sentTemp;

        for (uint256 i = 0; i < loanIds.length; i++) {
            loan = proto.loan[loanIds[i]];
            if (loan.borrower != msg.sender) {
                revert NotBorrowerOfTheLoan(loanIds[i]);
            }
            if (loan.payment.borrowerClaimed) {
                revert BorrowerAlreadyClaimed(loanIds[i]);
            }
            loan.payment.borrowerClaimed = true;
            if (loan.payment.liquidated) {
                sentTemp = loan.payment.paid.mul(ONE.sub(loan.shareLent)); // todo check paid price
            } else {
                sentTemp = 0;
            }
            if (sentTemp > 0) {
                loan.assetLent.checkedTransfer(msg.sender, sentTemp);
                sent += sentTemp;
                emit Claim(msg.sender, sentTemp, loanIds[i]);
            }
        }
    }

    /// @notice sends principal plus interests of the loan to `msg.sender`
    /// @param loan - to calculate amount from
    /// @param provision liquidity provision for this loan
    /// @return sent amount sent
    function sendInterests(Loan storage loan, Provision storage provision) internal returns (uint256 sent) {
        uint256 interests = loan.payment.paid - loan.lent;
        sent = provision.amount + (interests * (provision.amount)) / loan.lent;
        loan.assetLent.checkedTransfer(msg.sender, sent);
    }

    /// @notice sends liquidation share due to `msg.sender` as a supplier
    /// @param loan - from which the collateral were liquidated
    /// @param provision liquidity provisioned by this loan by the supplier
    /// @return sent amount sent
    function sendShareOfSaleAsSupplier(
        Loan storage loan,
        Provision storage provision
    ) internal returns (uint256 sent) {
        sent = loan.payment.paid.mul(provision.share);
        loan.assetLent.checkedTransfer(msg.sender, sent);
    }
}
