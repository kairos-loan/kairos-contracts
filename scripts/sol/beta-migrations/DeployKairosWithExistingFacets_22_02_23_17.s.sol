// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
import {Diamond, DiamondArgs} from "diamond/contracts/Diamond.sol";
import {DiamondCutFacet} from "diamond/contracts/facets/DiamondCutFacet.sol";
import {OwnershipFacet} from "diamond/contracts/facets/OwnershipFacet.sol";
import {IDiamondCut} from "diamond/contracts/interfaces/IDiamondCut.sol";
import {IDiamond} from "diamond/contracts/interfaces/IDiamond.sol";
import {DiamondLoupeFacet} from "diamond/contracts/facets/DiamondLoupeFacet.sol";
import {console} from "forge-std/console.sol";

import {Ray} from "../../../src/DataStructure/Objects.sol";
import {RayMath} from "../../../src/utils/RayMath.sol";
import {ONE} from "../../../src/DataStructure/Global.sol";
import {IKairos} from "../../../src/interface/IKairos.sol";
import {External} from "../../../test/Commons/External.sol";
import {ContractsCreator} from "../../../src/ContractsCreator.sol";
import {AuctionFacet} from "../../../src/AuctionFacet.sol";
import {BorrowFacet} from "../../../src/BorrowFacet.sol";
import {ClaimFacet} from "../../../src/ClaimFacet.sol";
import {Initializer} from "../../../src/Initializer.sol";
import {BetaInitializer} from "../../../src/BetaInitializer.sol";
import {ProtocolFacet} from "../../../src/ProtocolFacet.sol";
import {RepayFacet} from "../../../src/RepayFacet.sol";
import {AdminFacet} from "../../../src/AdminFacet.sol";
import {SupplyPositionFacet} from "../../../src/SupplyPositionFacet.sol";

//                            format is dd_mm_yy_hh
contract DeployKairosWithExistingFacets_22_02_23_17 is Script, ContractsCreator {
    using RayMath for Ray;

    /* solhint-disable-next-line function-max-lines */
    function run() public {
        uint256 deployerKey = vm.envUint("DEPLOYER_KEY");
        address deployer = vm.addr(deployerKey);

        vm.startBroadcast(deployerKey);
        initializer = Initializer(address(new BetaInitializer()));
        vm.stopBroadcast();

        cut = DiamondCutFacet(0xFa2f918a7feD7263e5C4553f1d589f443c7Ed035);
        ownership = OwnershipFacet(0xffa6031B0C4e9764b51Eb56758878F40bA7DCd00);
        loupe = DiamondLoupeFacet(0xE7fc385DAa0a201ea2094add4e45E64C8430cD6D);
        borrow = BorrowFacet(0xc1245349b45D60065C060600Ba061a7aeC989aa6);
        supplyPosition = SupplyPositionFacet(0x3Ed9ff4554218FD96F8E24C164953B009B065F21);
        protocol = ProtocolFacet(0x164A56A4F63DA1954c0b16931C45Cc44ec0729eB);
        repay = RepayFacet(0x1dd2E26F401a36D390e74a4FfFCCDB2beFb47597);
        auction = AuctionFacet(0xB0cA176E7881b108ef3D899dD814902a2aBe8b52);
        claim = ClaimFacet(0x9f088b0a2fc1bec51325CFb1F914d02b38146BdF);
        admin = AdminFacet(0xa265aF8F13126Dd01BD00E7BE105C0e43204Ef14);

        vm.startBroadcast(deployerKey);
        DiamondArgs memory args = DiamondArgs({
            owner: deployer,
            init: address(initializer),
            initCalldata: abi.encodeWithSelector(initializer.init.selector)
        });
        IKairos newKairos = IKairos(address(new Diamond(getFacetCuts(), args)));
        vm.stopBroadcast();

        console.log("new kairos", address(newKairos));
        console.log("beta initializer", address(initializer));
    }
}
