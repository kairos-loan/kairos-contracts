// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {BuyArgs, NFToken} from "../../src/DataStructure/Objects.sol";
import {ERC721CallerIsNotOwnerNorApproved} from "../../src/DataStructure/ERC721Errors.sol";
import {External} from "../Commons/External.sol";
import {Loan, Provision} from "../../src/DataStructure/Storage.sol";
import {LoanAlreadyRepaid, SupplyPositionDoesntBelongToTheLoan} from "../../src/DataStructure/Errors.sol";

contract TestAuction is External {
    // test simplest case of auction
    function testSimpleAuction() public {
        auctionN(1);
    }

    function testMultipleAuctions() public {
        auctionN(10);
    }

    function testLoanAlreadyRepaid() public {
        Loan memory loan = getLoan();
        loan.payment.paid = 1 ether;
        BuyArgs[] memory args = storeAndGetArgs(loan);
        vm.expectRevert(abi.encodeWithSelector(LoanAlreadyRepaid.selector, 1));
        kairos.buy(args);
    }

    function testErc721CallerIsNotOwnerNorApproved() public {
        BuyArgs[] memory args = setupLoan();
        args[0].positionIds = oneInArray;
        mintPosition(signer2, getProvision());
        // nft.mintOneTo(address(kairos));
        vm.startPrank(signer);
        vm.expectRevert(abi.encodeWithSelector(ERC721CallerIsNotOwnerNorApproved.selector));
        kairos.buy(args);
    }

    function testSupplyPositionDoesntBelongToTheLoan() public {
        Provision memory provision = getProvision();
        provision.loanId = 2;
        mintPosition(signer, provision);
        BuyArgs[] memory args = setupLoan();
        args[0].positionIds = oneInArray;
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

    function testPaidPrice() public {
        BuyArgs[] memory args = new BuyArgs[](1);
        getFlooz(signer, money);
        uint256 balanceBefore = money.balanceOf(signer);
        nft.mintOneTo(address(kairos));
        args[0] = setupLoan(1)[0];
        skip(3600);
        vm.prank(signer);
        kairos.buy(args);
        assertEq(balanceBefore - money.balanceOf(signer), kairos.price(1));
    }

    function auctionN(uint256 nbOfAuctions) internal {
        BuyArgs[] memory args = new BuyArgs[](nbOfAuctions);
        getFlooz(signer, money, nbOfAuctions * 1 ether);
        for (uint8 i; i < nbOfAuctions; i++) {
            nft.mintOneTo(address(kairos));
            args[i] = setupLoan(i + 1)[0];
        }
        vm.prank(signer);
        kairos.buy(args);
        for (uint8 i; i < nbOfAuctions; i++) {
            assertEq(nft.ownerOf(i + 1), signer);
        }
        assertEq(money.balanceOf(signer), 0);
        assertEq(money.balanceOf(address(kairos)), nbOfAuctions * 1 ether);
    }

    function getLoan() internal view override returns (Loan memory loan) {
        loan = _getLoan();
        // price should be the same as lent amount (initial = lent * 3, duration : 3 days)
        loan.endDate = block.timestamp - 2 days;
    }

    function storeAndGetArgs(Loan memory loan, uint256 loanId) private returns (BuyArgs[] memory) {
        BuyArgs[] memory args = new BuyArgs[](1);
        store(loan, loanId);
        args[0] = BuyArgs({loanId: loanId, to: signer, positionIds: emptyArray});
        return args;
    }

    function storeAndGetArgs(Loan memory loan) private returns (BuyArgs[] memory) {
        return storeAndGetArgs(loan, 1);
    }

    function setupLoan(uint256 loanAndNftId) private returns (BuyArgs[] memory) {
        Loan memory loan = getLoan();
        loan.collateral = NFToken({implem: nft, id: loanAndNftId});
        return storeAndGetArgs(loan, loanAndNftId);
    }

    function setupLoan() private returns (BuyArgs[] memory) {
        return setupLoan(1);
    }
}
