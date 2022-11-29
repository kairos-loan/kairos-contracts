// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./Commons/External.sol";

contract TestAuction is External {
    // test simplest case of auction
    function testSimpleAuction() public {
        BuyArgs[] memory args = new BuyArgs[](1);
        uint256[] memory positionIds = new uint256[](1);
        positionIds[0] = 1;
        args[0] = BuyArgs({loanId: 1, to: signer2, positionIds: positionIds});
        Loan memory loan = getLoan();
        loan.startDate = block.timestamp - 1 weeks;
        loan.endDate = block.timestamp - 2 days; // price should be the same as lent amount
        store(loan, 1);
        mintPosition(signer, getProvision());
        nft.mintOneTo(address(kairos));
        vm.prank(signer);
        kairos.buy(args);
        assertEq(nft.ownerOf(1), signer2);
        vm.expectRevert(ERC721InvalidTokenId.selector);
        assertEq(kairos.ownerOf(1), address(0));
    }
    // todo #13 test multiple auctions

    function testMultipleAuctions() public {
        auctionN(2);
    }

    function auctionN(uint8 nbOfAuctions) internal {
        BuyArgs[] memory args = new BuyArgs[](nbOfAuctions);
        uint256[] memory positionIds = new uint256[](nbOfAuctions);

        for(uint8 i; i< nbOfAuctions; i++){
            positionIds[i]=i+1;
            args[i] = BuyArgs({loanId: i+1, to: signer2, positionIds: positionIds});
            Loan memory loan = getLoan();
            loan.supplyPositionIndex = i;
            loan.startDate = block.timestamp - 1 weeks;
            loan.endDate = block.timestamp - 2 days; // price should be the same as lent amount
            store(loan, i);
            Provision memory provision = getProvision();
            provision.loanId = i;
            mintPosition(signer, provision);
            nft.mintOneTo(address(kairos));
        }
        vm.prank(signer);
        kairos.buy(args);
        assertEq(nft.ownerOf(1), signer2);
        vm.expectRevert(ERC721InvalidTokenId.selector);
        assertEq(kairos.ownerOf(1), address(0));
    }
}
