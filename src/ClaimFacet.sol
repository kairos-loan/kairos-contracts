// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {IClaimFacet} from "./interface/IClaimFacet.sol";
import {BorrowerAlreadyClaimed, ERC20TransferFailed, NotBorrowerOfTheLoan} from "./DataStructure/Errors.sol";
import {ERC721CallerIsNotOwnerNorApproved} from "./DataStructure/ERC721Errors.sol";
import {Loan, Protocol, Provision, SupplyPosition} from "./DataStructure/Storage.sol";
import {ONE, protocolStorage, supplyPositionStorage} from "./DataStructure/Global.sol";
import {Ray} from "./DataStructure/Objects.sol";
import {RayMath} from "./utils/RayMath.sol";
import {SafeMint} from "./SupplyPositionLogic/SafeMint.sol";

/// @notice claims supplier and borrower rights on loans or supply positions
contract ClaimFacet is IClaimFacet, SafeMint {
    using RayMath for Ray;
    using RayMath for uint256;

    /// @notice some liquidity has been claimed as principal plus interests or share of liquidation
    /// @param claimant who received the liquidity
    /// @param claimed amount sent
    /// @param loanId loan identifier where the claim rights come from
    event Claim(address indexed claimant, uint256 indexed claimed, uint256 indexed loanId);

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

        for (uint8 i = 0; i < positionIds.length; i++) {
            if (!_isApprovedOrOwner(msg.sender, positionIds[i])) {
                revert ERC721CallerIsNotOwnerNorApproved();
            }
            _burn(positionIds[i]);
            provision = sp.provision[positionIds[i]];
            loanId = provision.loanId;
            loan = proto.loan[loanId];
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

        for (uint8 i = 0; i < loanIds.length; i++) {
            loan = proto.loan[loanIds[i]];
            if (loan.borrower != msg.sender) {
                revert NotBorrowerOfTheLoan(loanIds[i]);
            }
            if (loan.payment.borrowerClaimed || loan.payment.borrowerBought) {
                revert BorrowerAlreadyClaimed(loanIds[i]);
            }
            loan.payment.borrowerClaimed = true;
            sentTemp = loan.payment.liquidated ? loan.payment.paid.mul(ONE.sub(loan.shareLent)) : 0;
            if (!loan.assetLent.transfer(msg.sender, sentTemp)) {
                revert ERC20TransferFailed(loan.assetLent, address(this), msg.sender);
            }
            if (sentTemp > 0) {
                emit Claim(msg.sender, sentTemp, loanIds[i]);
            }
            sent += sentTemp;
        }
    }

    /// @notice sends principal plus interests of the loan to `msg.sender`
    /// @param loan - to calculate amount from
    /// @param provision liquidity provision for this loan
    /// @return sent amount sent
    function sendInterests(Loan storage loan, Provision storage provision) internal returns (uint256 sent) {
        Ray shareOfTotalLent = provision.amount.div(loan.lent);
        sent = provision.amount + (loan.payment.paid - loan.lent).mul(shareOfTotalLent);
        if (!loan.assetLent.transfer(msg.sender, sent)) {
            revert ERC20TransferFailed(loan.assetLent, address(this), msg.sender);
        }
    }

    /// @notice sends liquidation share due to `msg.sender` as a supplier
    /// @param loan - from which the collateral were liquidated
    /// @param provision liquidity provisioned by this loan by the supplier
    /// @return sent amount sent
    function sendShareOfSaleAsSupplier(
        Loan storage loan,
        Provision storage provision
    ) internal returns (uint256 sent) {
        sent = loan.payment.borrowerBought
            ? loan.payment.paid.mul(provision.share).div(loan.shareLent)
            : loan.payment.paid.mul(provision.share);

        if (!loan.assetLent.transfer(msg.sender, sent)) {
            revert ERC20TransferFailed(loan.assetLent, address(this), msg.sender);
        }
    }
}
