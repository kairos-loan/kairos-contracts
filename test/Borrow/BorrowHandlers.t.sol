// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {CollateralState, NFToken, Offer, OfferArgs} from "../../src/DataStructure/Objects.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Internal} from "../Commons/Internal.sol";
import {Loan} from "../../src/DataStructure/Storage.sol";
import {RayMath} from "../../src/utils/RayMath.sol";
import {RequestedAmountTooHigh, InconsistentAssetRequests} from "../../src/DataStructure/Errors.sol";
import {ONE, Ray, supplyPositionStorage} from "../../src/DataStructure/Global.sol";
import {TestCommons} from "../Commons/TestCommons.sol";

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

    function testRequestedAmountTooHigh() public {
        CollateralState memory collatState = getCollateralState();
        Offer memory offer = getOffer();
        OfferArgs memory offArgs = getOfferArg(offer);

        offArgs.amount = 11 ether;

        vm.expectRevert(
            abi.encodeWithSelector(RequestedAmountTooHigh.selector, offArgs.amount, offer.loanToValue, offer)
        );
        this.useOfferExternal(offArgs, collatState);
    }

    function testUseCollateralNominal() public returns (Loan memory loan) {
        Offer memory offer = getOffer();
        OfferArgs[] memory offArgs = getOfferArgs(offer);
        NFToken memory nft = getNft();

        vm.mockCall(
            address(money),
            abi.encodeWithSelector(IERC20.transferFrom.selector, signer, BORROWER, offArgs[0].amount),
            abi.encode(true)
        );

        return this.useCollateralExternal(offArgs, BORROWER, nft);
    }

    function testUseOfferReturn() public {
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
    }

    function testMultipleUseCollateral() public {
        OfferArgs[] memory offerArgs = new OfferArgs[](10);

        for (uint8 i; i < 10; i++) {
            offerArgs[i] = getOfferArg(getOffer());
        }

        vm.mockCall(
            address(money),
            abi.encodeWithSelector(IERC20.transferFrom.selector, signer, BORROWER, offerArgs[0].amount),
            abi.encode(true)
        );
        this.useCollateralExternal(offerArgs, BORROWER, getNft());
    }

    function testUseCollateralReturn() public {
        Loan memory loan = getLoan();
        loan.shareLent = ONE.div(10);
        loan.startDate = block.timestamp;
        loan.endDate = block.timestamp + 2 weeks;
        assertEq(testUseCollateralNominal(), loan);
    }

    // todo #48 test use collateral puts loan at correct id
}
