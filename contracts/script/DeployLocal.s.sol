// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "diamond/Diamond.sol";
import "../ContractsCreator.sol";
import "contracts/test/TestCommons.sol";

/// @dev deploy script intended for local testing
contract DeployLocal is Script, ContractsCreator, TestCommons {
    function run() public {
        uint256 pKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80; // usual test key
        address testAddress = vm.addr(pKey);
        string memory toWrite;
        IKairos kairos;

        vm.startBroadcast(pKey);
        createContracts();
        DiamondArgs memory args = DiamondArgs({
            owner: testAddress,
            init: address(initializer),
            initCalldata: abi.encodeWithSelector(initializer.init.selector)
        });
        kairos = IKairos(address(new Diamond(getFacetCuts(), args)));

        money = new Money();
        nft = new NFT("Test NFTs", "TNFT");
        money.approve(address(kairos), 100 ether);

        toWrite = addConst(toWrite, "KAIROS_ADDR", vm.toString(address(kairos)));
        toWrite = addConst(toWrite, "SIGNATURE", vm.toString(
            getSignatureFromKey(
                Root({root: keccak256(
                    abi.encode(getOffer())
                )}),
                pKey, kairos
            )
        ));
        toWrite = addConst(toWrite, "MONEY_ADDR", vm.toString(address(money)));
        toWrite = addConst(toWrite, "NFT_ADDR", vm.toString(address(nft)));
        vm.writeFile("./generated/deployment.js", toWrite);
    }

    function addConst(
        string memory written,
        string memory name,
        string memory const
    ) internal returns(string memory toWrite) {
        toWrite = string.concat(written, "export const ");
        toWrite = string.concat(toWrite, name);
        toWrite = string.concat(toWrite, " = '");
        toWrite = string.concat(toWrite, const);
        toWrite = string.concat(toWrite, "'\n");
    }
}