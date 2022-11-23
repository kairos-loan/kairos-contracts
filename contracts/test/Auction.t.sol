// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./SetUp.sol";

contract TestAuction is SetUp {
    // test simplest case of auction
    function testSimpleAuction() public {
        BuyArgs[] memory args = new BuyArgs[](1);
        uint256[] memory positionIds = new uint256[](1);
        positionIds[0] = 1;
        args[0] = BuyArgs({loanId: 1, to: signer2, positionIds: positionIds});
        Loan memory loan = getDefaultLoan();
        loan.startDate = block.timestamp - 1 weeks;
        loan.endDate = block.timestamp - 2 days; // price should be the same as lent amount
        store(loan, 1);
        mintPosition(signer, getDefaultProvision());
        nft.transferFrom(address(this), address(kairos), 1);
        vm.prank(signer);
        kairos.buy(args);
        assertEq(nft.ownerOf(1), signer2);
        vm.expectRevert(ERC721InvalidTokenId.selector);
        assertEq(kairos.ownerOf(1), address(0));
    }
    // todo #13 test multiple auctions
}
