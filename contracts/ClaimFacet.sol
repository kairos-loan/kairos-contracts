// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./DataStructure/Global.sol";
import "./SupplyPositionLogic/NFTUtils.sol";
import "./utils/RayMath.sol";

/// @notice claims supplier and borrower rights on loans or supply positions
contract ClaimFacet is NFTUtils {
    using RayMath for Ray;
    using RayMath for uint256;

    event Claim(address indexed claimant, uint256 indexed claimed, uint256 indexed loanId);

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
            sentTemp = loan.liquidated
                ? sendShareOfSaleAsSupplier(loan, provision)
                : sendInterests(loan, provision);
            emit Claim(msg.sender, sentTemp, loanId);
            sent += sentTemp;
            _burn(positionIds[i]);
        }
    }

    function claimAsBorrower(uint256[] calldata loanIds) external returns(uint256 sent) {
        Protocol storage proto = protocolStorage();
        Loan storage loan;
        uint256 sentTemp;

        for (uint8 i; i < loanIds.length; i++) {
            loan = proto.loan[loanIds[i]];
            if (loan.borrower != msg.sender) { revert NotBorrowerOfTheLoan(loanIds[i]); }
            if (loan.borrowerClaimed) { revert BorrowerAlreadyClaimed(loanIds[i]); }
            loan.borrowerClaimed = true;
            sentTemp = loan.liquidated
                ? loan.repaid.mul(ONE.sub(loan.shareLent))
                : 0;
            loan.assetLent.transfer(msg.sender, sentTemp);
            emit Claim(msg.sender, sentTemp, loanIds[i]);
            sent += sentTemp;
        }
    }

    /// @notice sends principal plus interests of the loan to `msg.sender`
    function sendInterests(Loan storage loan, Provision storage provision) private returns(uint256 sent) {
        sent = loan.repaid.mul(provision.share);
        loan.assetLent.transfer(msg.sender, sent);
    }

    function sendShareOfSaleAsSupplier(Loan storage loan, Provision storage provision) private returns(uint256 sent) {
        sent = loan.borrowerClaimed
            ? loan.repaid.mul(provision.share.div(loan.shareLent))
            : loan.repaid.mul(provision.share);
        loan.assetLent.transfer(msg.sender, sent);
    }
}