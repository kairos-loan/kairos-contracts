// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./SetUp.sol";
import "../DataStructure/Objects.sol";

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

    function testMultipleAuction() public {
        BuyArgs[] memory args = new BuyArgs[](2);
        uint256[] memory positionIds1 = new uint256[](1);
        uint256[] memory positionIds2 = new uint256[](1);
        positionIds1[0] = 1;
        positionIds2[0] = 2;
        args[0] = BuyArgs({loanId: 1, to: signer2, positionIds: positionIds1});
        args[1] = BuyArgs({loanId: 2, to: signer2, positionIds: positionIds2});
        Loan[] memory loans = getMultipleLoan(2);

        loans[0].startDate = block.timestamp - 1 weeks;
        loans[0].endDate = block.timestamp - 2 days; // price should be the same as lent amount
        loans[0].collateral.id = 1;
        loans[1].startDate = block.timestamp - 1 weeks;
        loans[1].endDate = block.timestamp - 1 weeks;
        loans[1].collateral.id = 2;

        store(loans[0], 1);
        store(loans[1], 2);

        Provision memory provision1 = getCustomProvision(1);
        Provision memory provision2 = getCustomProvision(2);

        mintPosition(signer, provision1);
        mintPosition(signer, provision2);
        uint256 tokenId = nft.mintOne();

        nft.transferFrom(address(this), address(kairos), 1);
        nft.transferFrom(address(this), address(kairos), tokenId);

        vm.prank(signer);
        kairos.buy(args);
        assertEq(nft.ownerOf(1), signer2);
        vm.expectRevert(ERC721InvalidTokenId.selector);
        assertEq(kairos.ownerOf(1), address(0));
    }
}
