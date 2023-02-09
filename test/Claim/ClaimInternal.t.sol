// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {BorrowerAlreadyClaimed, NotBorrowerOfTheLoan} from "../../src/DataStructure/Errors.sol";
import {ERC721InvalidTokenId} from "../../src/DataStructure/ERC721Errors.sol";
import {Internal} from "../Commons/Internal.sol";
import {Loan, Protocol, Provision, SupplyPosition} from "../../src/DataStructure/Storage.sol";
import {ONE, protocolStorage, supplyPositionStorage} from "../../src/DataStructure/Global.sol";
import {Ray} from "../../src/DataStructure/Objects.sol";
import {RayMath} from "../../src/utils/RayMath.sol";
import {console} from "forge-std/console.sol";

contract TestClaim is Internal {
    using RayMath for Ray;
    using RayMath for uint256;

    function testSendInterests() public {
        Protocol storage proto = protocolStorage();
        proto.loan[0] = getLoan();
        Loan memory loan = proto.loan[0];
        loan.lent = 2 ether;
        loan.payment.paid = loan.lent + 1;

        SupplyPosition storage sp = supplyPositionStorage();
        sp.provision[0] = getProvision();
        sp.provision[0].amount = 1 ether;
        Provision memory provision = sp.provision[0];

        // Ray shareOfTotalLent = provision.amount.div(loan.lent); // 1/1000
        // console.log((loan.payment.paid - loan.lent).mul(shareOfTotalLent));
        // uint256 sent = provision.amount + (loan.payment.paid - loan.lent).mul(shareOfTotalLent);
        // console.log("sent1", sent);

        uint256 interests = loan.payment.paid - loan.lent;
        uint256 sent2 = provision.amount + (interests * (provision.amount)) / (loan.lent);

        // console.log("sent2", sent);
        // assert(sent == sent2);

        // vm.expectCall(address(loan.assetLent), abi.encodeCall(loan.assetLent.transfer, (msg.sender, sent2)));
        // loan.assetLent.transfer(msg.sender, sent2);

        console.log(address(this));
        console.log(address(money));

        vm.expectCall(address(money), abi.encodeWithSelector(money.transfer.selector, address(this), sent2));

        // money.transfer(address(this), 10);

        this.sendInterestsExternal(loan, provision);
    }
}
