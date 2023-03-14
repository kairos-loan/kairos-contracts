// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Internal} from "../Commons/Internal.sol";
import {Loan, Protocol, Provision, SupplyPosition} from "../../src/DataStructure/Storage.sol";
import {protocolStorage, supplyPositionStorage, ONE} from "../../src/DataStructure/Global.sol";
import {Ray} from "../../src/DataStructure/Objects.sol";
import {RayMath} from "../../src/utils/RayMath.sol";

contract TestClaim is Internal {
    using RayMath for Ray;
    using RayMath for uint256;

    Loan private loan;
    Provision private provision;
    uint256 private sentExpected;

    function setUp() public {
        loan = getLoan();
        loan.lent = 2 ether;
        loan.payment.paid = (14 * loan.lent) / 10; // 40% interests;
        provision = getProvision();
        provision.amount = loan.lent / 2;
        sentExpected = loan.payment.paid / 2;
    }

    function testSendInterests() public {
        vm.mockCall(
            address(money),
            abi.encodeWithSelector(money.transfer.selector, address(this), sentExpected),
            abi.encode(true)
        );
        assertEq(this.sendInterestsExternal(loan, provision), sentExpected);
    }

    function testSendInterestsWithLowLent() public {
        loan.lent = 2;
        provision.amount = 1;
        loan.payment.paid = (14 * loan.lent) / 10;

        vm.mockCall(
            address(money),
            abi.encodeWithSelector(money.transfer.selector, address(this), provision.amount),
            abi.encode(true)
        );
        assertEq(this.sendInterestsExternal(loan, provision), provision.amount);
    }

    function testSendInterestsWithNoInterest() public {
        loan.payment.paid = loan.lent;

        vm.mockCall(
            address(money),
            abi.encodeWithSelector(money.transfer.selector, address(this), provision.amount),
            abi.encode(true)
        );
        assertEq(this.sendInterestsExternal(loan, provision), provision.amount);
    }

    function testSendShareOfSaleAsSupplier() public {
        uint256 paid = 1 ether;
        loan.payment.paid = paid;
        provision.share = ONE.div(2);
        sentExpected = paid / 2;
        vm.mockCall(
            address(money),
            abi.encodeWithSelector(money.transfer.selector, address(this), sentExpected),
            abi.encode(true)
        );
        assertEq(this.sendShareOfSaleAsSupplierExternal(loan, provision), sentExpected);
    }
}
