// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {ERC20TransferFailed} from "../../src/DataStructure/Errors.sol";
import {Internal} from "../Commons/Internal.sol";
import {Loan, Protocol, Provision, SupplyPosition} from "../../src/DataStructure/Storage.sol";
import {protocolStorage, supplyPositionStorage} from "../../src/DataStructure/Global.sol";
import {Ray} from "../../src/DataStructure/Objects.sol";
import {RayMath} from "../../src/utils/RayMath.sol";

contract TestClaim is Internal {
    using RayMath for Ray;
    using RayMath for uint256;

    function testSendInterests() public {
        Protocol storage proto = protocolStorage();
        Loan memory loan = proto.loan[0];
        loan = getLoan();
        loan.lent = 2 ether;
        loan.payment.paid = (14 * loan.lent) / 10; // 40% interests;

        SupplyPosition storage sp = supplyPositionStorage();
        Provision memory provision = sp.provision[0];
        provision = getProvision();
        provision.amount = loan.lent / 2;

        uint256 sentExpected = loan.payment.paid / 2;

        vm.mockCall(
            address(money),
            abi.encodeWithSelector(money.transfer.selector, address(this), sentExpected),
            abi.encode(false)
        );
        vm.expectRevert(
            abi.encodeWithSelector(ERC20TransferFailed.selector, address(money), address(this), address(this))
        );
        this.sendInterestsExternal(loan, provision);

        vm.mockCall(
            address(money),
            abi.encodeWithSelector(money.transfer.selector, address(this), sentExpected),
            abi.encode(true)
        );
        assertEq(this.sendInterestsExternal(loan, provision), sentExpected);
    }

    function testSendInterestsWithLowLent() public {
        Protocol storage proto = protocolStorage();
        proto.loan[0] = getLoan();
        Loan memory loan = proto.loan[0];
        loan.lent = 2;
        loan.payment.paid = (14 * loan.lent) / 10;

        SupplyPosition storage sp = supplyPositionStorage();
        Provision memory provision = sp.provision[0];
        provision = getProvision();
        provision.amount = 1;

        vm.mockCall(
            address(money),
            abi.encodeWithSelector(money.transfer.selector, address(this), provision.amount),
            abi.encode(true)
        );
        assertEq(this.sendInterestsExternal(loan, provision), provision.amount);
    }

    function testSendInterestsWithNulInterest() public {
        Protocol storage proto = protocolStorage();
        proto.loan[0] = getLoan();
        Loan memory loan = proto.loan[0];
        loan.lent = 2 ether;
        loan.payment.paid = loan.lent;

        SupplyPosition storage sp = supplyPositionStorage();
        Provision memory provision = sp.provision[0];
        provision = getProvision();
        provision.amount = loan.lent / 2;

        vm.mockCall(
            address(money),
            abi.encodeWithSelector(money.transfer.selector, address(this), provision.amount),
            abi.encode(true)
        );
        assertEq(this.sendInterestsExternal(loan, provision), provision.amount);
    }
}
