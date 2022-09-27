// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "diamond/Diamond.sol";
import "../ContractsCreator.sol";

contract Deploy is Script, ContractsCreator {
    function run() public {
        vm.broadcast();
        createContracts();
        Diamond diamond = new Diamond(address(this), address(cut));
        IDiamondCut(address(diamond)).diamondCut(
            getFacetCuts(), address(initializer), abi.encodeWithSelector(initializer.init.selector));
    }
}