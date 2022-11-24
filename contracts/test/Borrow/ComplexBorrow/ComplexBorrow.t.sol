// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "contracts/utils/RayMath.sol";
import "./PreExecFuncs.sol";

contract TestComplexBorrow is ComplexBorrowPreExecFuncs {
    using RayMath for Ray;
    using RayMath for uint256;

    // should pass in a scenario as complex as possible
    // should borrow from 2 NFTs, one of which should borrow from 2 offers of different suppliers
    // use different cryptos for the 2 NFTs
    // NFT 1 : from collec1 with money1 with 2 suppliers
    // NFT 2 : from collec2 with money2 with 1 supplier
    // NFT 1 : 25% from supp1 at 2 eth valuation, 75% from supp2 at 1 eth val
    function testComplexBorrow() public {
        ComplexBorrowData memory d; // d as data
        d.m1InitialBalance = money.balanceOf(address(this));
        d.m2InitialBalance = money2.balanceOf(address(this));

        prepareSigners();
        d = initOffers(d);
        d = initOfferArgs(d);
        d = initBorrowArgs(d);

        execBorrowAndCheckSupplyPos(d);
        checkBalances(d);
        checkLoans();
    }

    function execBorrowAndCheckSupplyPos(ComplexBorrowData memory d) private {
        BorrowArgs[] memory batchbargs = new BorrowArgs[](2);
        batchbargs[0] = d.bargs1;
        batchbargs[1] = d.bargs2;

        vm.prank(BORROWER);
        kairos.borrow(batchbargs);
        assertEq(kairos.balanceOf(signer), 2);
        assertEq(kairos.balanceOf(signer2), 1);
        Provision memory supp1pos1 = kairos.position(1);
        Provision memory supp2pos = kairos.position(2);
        Provision memory supp1pos2 = kairos.position(3);
        assertEq(supp1pos1.amount, 1 ether / 2);
        assertEq(supp2pos.amount, 3 ether / 4);
        assertEq(supp1pos2.amount, 1 ether);
        assertEq(supp1pos1.share, ONE.div(4));
        assertEq(supp2pos.share, ONE.div(4).mul(3));
        assertEq(supp1pos2.share, ONE.div(2));
    }

    function checkBalances(ComplexBorrowData memory d) private {
        // supplier money balances
        assertEq(money.balanceOf(signer), (1 ether / 2) * 3, "sig1 m1 bal pb");
        assertEq(money.balanceOf(signer2), (1 ether / 4) * 5, "sig2 m1 bal pb");
        assertEq(money2.balanceOf(signer), 1 ether, "sig1 m2 bal pb");

        // borrower money balances
        assertEq(money.balanceOf(BORROWER), ((1 ether / 4) * 5) + d.m1InitialBalance, "bor m1 bal pb");
        assertEq(money2.balanceOf(BORROWER), (1 ether) + d.m2InitialBalance, "bor m2 bal pb");

        // nft balances
        assertEq(nft.balanceOf(BORROWER), 0);
        assertEq(nft2.balanceOf(BORROWER), 0);
        assertEq(nft.balanceOf(address(kairos)), 1);
        assertEq(nft.balanceOf(address(kairos)), 1);
    }

    function checkLoans() private view {
        uint256[] memory supplyPositionIds2 = new uint256[](1);
        supplyPositionIds2[0] = 3;
        Ray tranche0Rate = getTranche(0);
        Payment memory payment;
        Loan memory loan2 = Loan({
            assetLent: money2,
            lent: 1 ether,
            shareLent: ONE.div(2),
            startDate: block.timestamp,
            endDate: block.timestamp + 4 weeks,
            interestPerSecond: tranche0Rate,
            borrower: BORROWER,
            collateral: NFToken({implem: nft2, id: 1}),
            payment: payment,
            supplyPositionIndex: 3,
            nbOfPositions: 1
        });
        assertEq(loan1(), kairos.getLoan(1));
        assertEq(loan2, kairos.getLoan(2));
    }

    function loan1() private view returns (Loan memory) {
        Ray tranche0Rate = kairos.getRateOfTranche(0);
        Payment memory payment;
        uint256[] memory supplyPositionIds1 = new uint256[](2);
        supplyPositionIds1[0] = 1;
        supplyPositionIds1[1] = 2;

        return
            Loan({
                assetLent: money,
                lent: (1 ether / 4) * 5,
                shareLent: ONE,
                startDate: block.timestamp,
                endDate: block.timestamp + 1 weeks,
                interestPerSecond: tranche0Rate,
                borrower: BORROWER,
                collateral: NFToken({implem: nft, id: 1}),
                payment: payment,
                supplyPositionIndex: 1,
                nbOfPositions: 2
            });
    }
}
