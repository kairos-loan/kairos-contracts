// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../Commons/External.sol";

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
        auctionN(10);
    }

    function testLoanAlreadyRepaid() public {
        BuyArgs[] memory args = new BuyArgs[](1);
        uint256[] memory positionIds = new uint256[](1);
        positionIds[0] = 1;
        args[0] = BuyArgs({loanId: 1, to: signer2, positionIds: positionIds});
        Loan memory loan = getLoan(); // price should be the same as lent amount
        loan.startDate = block.timestamp - 1 weeks;
        loan.endDate = block.timestamp - 2 days;
        loan.payment.paid = 1 ether;
        store(loan, 1);
        Provision memory provision = getProvision();
        provision.loanId = 1;
        mintPosition(signer, getProvision());
        nft.mintOneTo(address(kairos));
        vm.startPrank(signer);
        vm.expectRevert(abi.encodeWithSelector(LoanAlreadyRepaid.selector, positionIds[0]));
        kairos.buy(args);
    }

    function testErc721CallerIsNotOwnerNorApproved() public {
        BuyArgs[] memory args = new BuyArgs[](1);
        uint256[] memory positionIds = new uint256[](1);
        positionIds[0] = 1;
        args[0] = BuyArgs({loanId: 1, to: signer2, positionIds: positionIds});
        Loan memory loan = getLoan(); // price should be the same as lent amount
        loan.startDate = block.timestamp - 1 weeks;
        loan.endDate = block.timestamp - 2 days;
        store(loan, 1);
        mintPosition(signer2, getProvision());
        nft.mintOneTo(address(kairos));
        vm.startPrank(signer);
        vm.expectRevert(abi.encodeWithSelector(ERC721CallerIsNotOwnerNorApproved.selector));
        kairos.buy(args);
    }

    function testSupplyPositionDoesntBelongToTheLoan() public {
        BuyArgs[] memory args = new BuyArgs[](1);
        uint256[] memory positionIds = new uint256[](1);
        positionIds[0] = 1;
        args[0] = BuyArgs({loanId: 1, to: signer2, positionIds: positionIds});
        Loan memory loan = getLoan(); // price should be the same as lent amount
        loan.startDate = block.timestamp - 1 weeks;
        loan.endDate = block.timestamp - 2 days;
        store(loan, 1);
        Provision memory provision = getProvision();
        provision.loanId = 2;
        mintPosition(signer, provision);
        nft.mintOneTo(address(kairos));
        vm.startPrank(signer);
        vm.expectRevert(
            abi.encodeWithSelector(
                SupplyPositionDoesntBelongToTheLoan.selector,
                args[0].positionIds[0],
                args[0].loanId
            )
        );
        kairos.buy(args);
    }

    function auctionN(uint256 nbOfAuctions) internal {
        BuyArgs[] memory args = new BuyArgs[](nbOfAuctions);
        uint256[] memory positionIds = new uint256[](0);
        getFlooz(signer, money, nbOfAuctions * 4 ether);
        for (uint8 i; i < nbOfAuctions; i++) {
            uint256 tokenId = nft.mintOneTo(address(kairos));
            args[i] = BuyArgs({loanId: i + 1, to: signer, positionIds: positionIds});
            Loan memory loan = getLoan();
            loan.startDate = block.timestamp - 1 weeks;
            loan.endDate = block.timestamp - 2 days; // price should be the same as lent amount
            loan.collateral = NFToken({implem: nft, id: tokenId});
            store(loan, i + 1);
        }
        vm.prank(signer);
        kairos.buy(args);
    }
}
