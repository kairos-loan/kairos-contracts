// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "diamond/Diamond.sol";
import "../ContractsCreator.sol";

contract Deploy is Script, ContractsCreator {
    function run() public {
        vm.startBroadcast();
        createContracts();
        Diamond diamond = new Diamond(msg.sender, address(cut));
        IDiamondCut(address(diamond)).diamondCut(
            getFacetCuts(), address(initializer), abi.encodeWithSelector(initializer.init.selector));
        console.log("deployed at : ", address(diamond));
    }
}