// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./DataStructure/Global.sol";
import "./SupplyPositionLogic/NFTUtils.sol";
import "./utils/RayMath.sol";

/// @notice claims supplier and borrower rights on loans or supply positions
contract ClaimFacet is NFTUtils {
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
    function claim(uint256[] calldata positionIds) external returns(uint256 sent) {
        Protocol storage proto = protocolStorage();
        SupplyPosition storage sp = supplyPositionStorage();
        Loan storage loan;
        Provision storage provision;
        uint256 loanId;
        uint256 sentTemp;

        for (uint8 i; i < positionIds.length; i++) {
            if (!_isApprovedOrOwner(msg.sender, positionIds[i])) { revert ERC721CallerIsNotOwnerNorApproved(); }
            provision = sp.provision[positionIds[i]];
            loanId = provision.loanId;
            loan = proto.loan[loanId];
            sentTemp = loan.payment.liquidated
                ? sendShareOfSaleAsSupplier(loan, provision)
                : sendInterests(loan, provision);
            emit Claim(msg.sender, sentTemp, loanId);
            sent += sentTemp;
            _burn(positionIds[i]);
        }
    }

    /// @notice claims share of liquidation due to a borrower who's collateral has been sold
    /// @param loanIds loan identifiers of one or multiple loans where the borrower wants to claim liquidation share
    /// @return sent amount sent
    function claimAsBorrower(uint256[] calldata loanIds) external returns(uint256 sent) {
        Protocol storage proto = protocolStorage();
        Loan storage loan;
        uint256 sentTemp;

        for (uint8 i; i < loanIds.length; i++) {
            loan = proto.loan[loanIds[i]];
            if (loan.borrower != msg.sender) { revert NotBorrowerOfTheLoan(loanIds[i]); }
            if (loan.payment.borrowerClaimed || loan.payment.borrowerBought) { 
                revert BorrowerAlreadyClaimed(loanIds[i]);
            }
            loan.payment.borrowerClaimed = true;
            sentTemp = loan.payment.liquidated
                ? loan.payment.paid.mul(ONE.sub(loan.shareLent))
                : 0;
            loan.assetLent.transfer(msg.sender, sentTemp);
            if (sentTemp > 0) { emit Claim(msg.sender, sentTemp, loanIds[i]); }
            sent += sentTemp;
        }
    }

    /// @notice sends principal plus interests of the loan to `msg.sender`
    /// @param loan - to calculate amount from
    /// @param provision liquidity provision for this loan
    /// @return sent amount sent
    function sendInterests(Loan storage loan, Provision storage provision) private returns(uint256 sent) {
        sent = loan.payment.paid.mul(provision.share.div(loan.shareLent));
        loan.assetLent.transfer(msg.sender, sent);
    }

    /// @notice sends liquidation share due to `msg.sender` as a supplier
    /// @param loan - from which the collateral were liquidated
    /// @param provision liquidity provisioned by this loan by the supplier
    /// @return sent amount sent
    function sendShareOfSaleAsSupplier(Loan storage loan, Provision storage provision) private returns(uint256 sent) {
        sent = loan.payment.borrowerBought
            ? loan.payment.paid.mul(provision.share.div(loan.shareLent))
            : loan.payment.paid.mul(provision.share);
        loan.assetLent.transfer(msg.sender, sent);
    }
}