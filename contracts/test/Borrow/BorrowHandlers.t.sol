// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../Commons/Internal.sol";

contract TestBorrowHandlers is Internal {
    using RayMath for uint256;
    using RayMath for Ray;
    // useOffer tests
    function testConsistentAssetRequests() public {
        CollateralState memory collatState = getCollateralState();
        Offer memory offer = getOffer();
        offer.assetToLend = money2;
        OfferArgs memory offArgs = getOfferArg(offer);

        vm.expectRevert(abi.encodeWithSelector(InconsistentAssetRequests.selector, money, money2));
        this.useOfferExternal(offArgs, collatState);

        collatState.assetLent = money2;
        vm.mockCall(
            address(money2),
            abi.encodeWithSelector(IERC20.transferFrom.selector, signer, BORROWER, offArgs.amount),
            abi.encode(true)
        );
        this.useOfferExternal(offArgs, collatState);
        assertEq(supplyPositionStorage().totalSupply, 1);
    }

    function testRequestedAmountTooHigh() public{
        CollateralState memory collatState = getCollateralState();
        Offer memory offer = getOffer();
        OfferArgs memory offArgs = getOfferArg(offer);

        offArgs.amount = 11 ether;

        vm.mockCall(
            address(money),
            abi.encodeWithSelector(IERC20.transferFrom.selector, signer, BORROWER, offArgs.amount),
            abi.encode(true)
        );
        vm.expectRevert(
            abi.encodeWithSelector(RequestedAmountTooHigh.selector, offArgs.amount, offer.loanToValue)
        );

        this.useOfferExternal(offArgs, collatState);
    }

    function testUseOfferReturn() public{
        CollateralState memory collatState = getCollateralState();
        Offer memory offer = getOffer();
        OfferArgs memory offArgs = getOfferArg(offer);
        vm.mockCall(
            address(money),
            abi.encodeWithSelector(IERC20.transferFrom.selector, signer, BORROWER, offArgs.amount),
            abi.encode(true)
        );
        CollateralState memory res = this.useOfferExternal(offArgs, collatState);

        Ray shareMatched = offArgs.amount.div(offer.loanToValue);
        collatState.matched = collatState.matched.add(shareMatched);

        assertEq(res, collatState);

        res.loanId = 3;
        vm.expectRevert(
            abi.encodeWithSelector(AssertionFailedCollatStateDontMatch.selector)
        );
        assertEq(res, collatState);
    }

    function testUseCollateral() public {
        Offer memory offer = getOffer();
        OfferArgs[] memory offArgs = getOfferArgs(offer);
        NFToken memory nft = getNft();

        vm.mockCall(
            address(money),
            abi.encodeWithSelector(IERC20.transferFrom.selector, signer, BORROWER, offArgs[0].amount),
            abi.encode(true)
        );

        this.useCollateralExternal(offArgs, BORROWER, nft);
    }

    function testMultipleUseCollateral() public {
        OfferArgs[] memory offerArgs = new OfferArgs[](10);

        for(uint8 i; i <10; i++ ){
            offerArgs[i]= getOfferArg(getOffer());
        }

        vm.mockCall(
            address(money),
            abi.encodeWithSelector(IERC20.transferFrom.selector, signer, BORROWER, offerArgs[0].amount),
            abi.encode(true)
        );
        this.useCollateralExternal(offerArgs, BORROWER, getNft());
    }

    function testUseCollateralReturn() public {

        OfferArgs[] memory offerArgs = new OfferArgs[](1);

        Payment memory payment;

    offerArgs[0]= getOfferArg(getOffer());

        Loan memory defaultLoan = Loan({
        assetLent: getOffer().assetToLend,
        lent: 1 ether,
        shareLent: ONE,
        startDate: block.timestamp,
        endDate: 2 weeks +1 seconds,
        interestPerSecond:getTranche(0), // todo #27 adapt rate to the offers
        borrower: BORROWER,
        collateral: getOffer().collateral,
        supplyPositionIndex: 1,
        payment: payment,
        nbOfPositions: 1
        });

        vm.mockCall(
            address(money),
            abi.encodeWithSelector(IERC20.transferFrom.selector, signer, BORROWER, offerArgs[0].amount),
            abi.encode(true)
        );

        Loan memory loan = this.useCollateralExternal(offerArgs, BORROWER, getNft());
        vm.expectRevert(
            abi.encodeWithSelector(AssertionFailedLoanDontMatch.selector)
        );
        assertEq(loan, defaultLoan);

    }



    //todo #28 finish TestBorrowHandlers
/*
    function testRequestAmountCheckAndAssetTransfer() public {
        CollateralState memory collatState;
        collatState.assetLent = money;
        OfferArgs memory args = getOfferArgs(getOffer());
        args.amount = 1 ether;
     }
*/






}
