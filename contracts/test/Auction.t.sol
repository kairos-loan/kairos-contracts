// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./SetUp.sol";

contract TestAuction is SetUp {
    using RayMath for Ray;
    using RayMath for uint256;

    // test simplest case of auction
    function testSimpleAuction() public {
        BuyArgs[] memory args = new BuyArgs[](1);
        uint256[] memory positionIds;
        args[0] = BuyArgs({
            loanId: 1,
            to: signer2,
            positionIds: positionIds
        });
        Loan memory loan = getDefaultLoan();
        loan.startDate = block.timestamp - 1 weeks;
        loan.endDate = block.timestamp - 2 days; // price should be the same as lent amount
        store(loan, 1);
        store(getDefaultProvision(), 1);
        nft.transferFrom(address(this), address(nftaclp), 1);
    }
}