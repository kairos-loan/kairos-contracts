// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "diamond/Diamond.sol";
import "../ContractsCreator.sol";
import "contracts/test/TestCommons.sol";

/// @dev deploy script intended for local testing
contract DeployLocal is Script, ContractsCreator, TestCommons {
    function run() public {
        IKairos kairos;

        vm.startBroadcast();
        createContracts();
        DiamondArgs memory args = DiamondArgs({
            owner: testAddress,
            init: address(initializer),
            initCalldata: abi.encodeWithSelector(initializer.init.selector)
        });
        kairos = IKairos(address(new Diamond(getFacetCuts(), args)));
    }
}