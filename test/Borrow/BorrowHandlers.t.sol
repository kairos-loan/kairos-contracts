// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {CollateralState, NFToken, Offer, OfferArg, Ray} from "../../src/DataStructure/Objects.sol";
import {Internal} from "../Commons/Internal.sol";
import {Loan} from "../../src/DataStructure/Storage.sol";
import {RayMath} from "../../src/utils/RayMath.sol";
import {RequestedAmountTooHigh} from "../../src/DataStructure/Errors.sol";
import {ONE, supplyPositionStorage, protocolStorage} from "../../src/DataStructure/Global.sol";
import {TestCommons} from "../Commons/TestCommons.sol";

contract TestBorrowHandlers is Internal {
    using RayMath for uint256;
    using RayMath for Ray;

    /// useOffer tests ///

    function testRequestedAmountTooHigh() public {
        CollateralState memory collatState = getCollateralState();
        Offer memory offer = getOffer();
        OfferArg memory offArgs = getOfferArg(offer);

        offArgs.amount = 11 ether;

        vm.expectRevert(
            abi.encodeWithSelector(RequestedAmountTooHigh.selector, offArgs.amount, offer.loanToValue, offer)
        );
        this.useOfferExternal(offArgs, collatState);
    }

    function testUseCollateralNominal() public returns (Loan memory loan) {
        Offer memory offer = getOffer();
        OfferArg[] memory offArgs = getOfferArgs(offer);
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
        OfferArg memory offArgs = getOfferArg(offer);
        vm.mockCall(
            address(money),
            abi.encodeWithSelector(IERC20.transferFrom.selector, signer, BORROWER, offArgs.amount),
            abi.encode(true)
        );
        (CollateralState memory res, address foundSigner) = this.useOfferExternal(offArgs, collatState);

        Ray shareMatched = offArgs.amount.div(offer.loanToValue);
        collatState.matched = collatState.matched.add(shareMatched);

        assertEq(foundSigner, signer);
        assertEq(res, collatState);
    }

    /// useCollateral tests ///

    function testUseCollateralReturn() public {
        Loan memory loan = getLoan();
        loan.shareLent = ONE.div(10);
        loan.startDate = block.timestamp;
        loan.endDate = block.timestamp + 2 weeks;
        assertEq(testUseCollateralNominal(), loan);
    }
}
