// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {External} from "./Commons/External.sol";
import {CallerIsNotOwner} from "../src/DataStructure/Errors.sol";

contract TestAdmin is External {
    function testOnlyOwner() public {
        vm.expectRevert(abi.encodeWithSelector(CallerIsNotOwner.selector, OWNER));
        kairos.setAuctionDuration(2);
    }
}
