// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "./DataStructure/Global.sol";
import "./utils/RayMath.sol";

// todo : docs

contract AuctionFacet {
    using RayMath for Ray;
    using RayMath for uint256;

    // function buy(uint256 loanId) external {

    // }

    function useLoan(uint256 loanId, uint256[] memory positionIds, address to) internal {
        Protocol storage proto = protocolStorage();
        Loan storage loan = proto.loan[loanId];
        Ray shareToPay = to == loan.borrower
            ? loan.shareLent : ONE;

        // wip

        if(to == loan.borrower) {
            shareToPay = shareToPay.sub(loan.shareLent);
        }
    }
}