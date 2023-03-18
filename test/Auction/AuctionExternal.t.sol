// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {BuyArg, NFToken} from "../../src/DataStructure/Objects.sol";
import {ERC721CallerIsNotOwnerNorApproved} from "../../src/DataStructure/ERC721Errors.sol";
import {External} from "../Commons/External.sol";
import {Loan, Provision} from "../../src/DataStructure/Storage.sol";
import {LoanAlreadyRepaid} from "../../src/DataStructure/Errors.sol";

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
        BuyArg[] memory args = storeAndGetArgs(loan);
        vm.expectRevert(abi.encodeWithSelector(LoanAlreadyRepaid.selector, 1));
        kairos.buy(args);
    }

    function testLoanAlreadyLiquidated() public {
        Loan memory loan = getLoan();
        loan.payment.liquidated = true;
        BuyArg[] memory args = storeAndGetArgs(loan);
        vm.expectRevert(abi.encodeWithSelector(LoanAlreadyRepaid.selector, 1));
        kairos.buy(args);
    }

    function testPaidPriceShouldBeTheSameAsReturnedByPriceMethod() public {
        BuyArg[] memory args = new BuyArg[](1);
        getFlooz(signer, money);
        uint256 balanceBefore = money.balanceOf(signer);
        nft.mintOneTo(address(kairos));
        args[0] = setupLoan(1)[0];
        skip(3600);
        uint256 price = kairos.price(1);
        vm.prank(signer);
        kairos.buy(args);
        assertEq(balanceBefore - money.balanceOf(signer), price);
    }

    function auctionN(uint256 nbOfAuctions) internal {
        BuyArg[] memory args = new BuyArg[](nbOfAuctions);
        getFlooz(signer, money, nbOfAuctions * 1 ether);
        for (uint256 i = 0; i < nbOfAuctions; i++) {
            nft.mintOneTo(address(kairos));
            args[i] = setupLoan(i + 1)[0];
        }
        vm.prank(signer);
        kairos.buy(args);
        for (uint256 i = 0; i < nbOfAuctions; i++) {
            assertEq(nft.ownerOf(i + 1), signer);
        }
        assertEq(money.balanceOf(signer), 0, "incorrect balance of signer");
        assertEq(money.balanceOf(address(kairos)), nbOfAuctions * 1 ether, "incorrect balance of kairos");
    }

    function getLoan() internal view override returns (Loan memory loan) {
        loan = _getLoan();
        // price should be the same as lent amount (initial = lent * 3, duration : 3 days)
        loan.endDate = block.timestamp - 2 days;
    }

    function setupLoan(uint256 loanAndNftId) private returns (BuyArg[] memory) {
        Loan memory loan = getLoan();
        loan.collateral = NFToken({implem: nft, id: loanAndNftId});
        return storeAndGetArgs(loan, loanAndNftId);
    }

    function setupLoan() private returns (BuyArg[] memory) {
        return setupLoan(1);
    }
}
