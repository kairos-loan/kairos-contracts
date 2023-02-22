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
import {ProtocolFacet} from "../../../src/ProtocolFacet.sol";
import {RepayFacet} from "../../../src/RepayFacet.sol";
import {SupplyPositionFacet} from "../../../src/SupplyPositionFacet.sol";
import {BetaSettersFacet} from "../../../src/BetaSettersFacet.sol";
import {betaSettersFS} from "./AddBetaSettersAndChangeParams.s.sol";

//                          format is dd_mm_yy_hh
contract UpdateAuctionBorrowAndKairos_27_01_23_14 is Script, ContractsCreator {
    using RayMath for Ray;

    /* solhint-disable-next-line function-max-lines */
    function run() public {
        uint256 deployerKey = vm.envUint("DEPLOYER_KEY");
        address deployer = vm.addr(deployerKey);

        initializer = Initializer(0x91516016578D47eC0E9b87Fe1419eDddE0B8d96C);
        cut = DiamondCutFacet(0x6630AA54CA78dADeb9482377a99cB66A8D02Ae6C);
        ownership = OwnershipFacet(0x5fDb5b44Aa0A0A5990602a029B0943c5bAF891fE);
        loupe = DiamondLoupeFacet(0x0ef28B1D103353Bd646fE22B11E9603E12EE0708);
        borrow = BorrowFacet(0x1cBAdDBf907ED0dc15B4EF9d4cBab7c346aAA43b); // new
        supplyPosition = SupplyPositionFacet(0x81d4831D08a6b9486574171E3EEE636296e50144);
        protocol = ProtocolFacet(0x47Da01054251fab085E35681fD33Bb4Fe4356116);
        repay = RepayFacet(0x96EC52dc82d3767092296eA89c9Fcf188399703e);
        auction = AuctionFacet(0x2c85eB15bCAbE40eee07cb5C52405F13249EB73F); // new
        claim = ClaimFacet(0xf4e3e6Bb0B70e8baf3Aabe6Df4fc9dE61b728ac9);
        BetaSettersFacet setters = BetaSettersFacet(0xC82460fe25434dCA26801C30a27DC9b2E2cdF62B);

        IDiamondCut.FacetCut[] memory betaFacetCuts = new IDiamondCut.FacetCut[](10);
        {
            IDiamondCut.FacetCut[] memory prodFacetCuts = getFacetCuts();
            betaFacetCuts[0] = prodFacetCuts[0];
            betaFacetCuts[1] = prodFacetCuts[1];
            betaFacetCuts[2] = prodFacetCuts[2];
            betaFacetCuts[3] = prodFacetCuts[3];
            betaFacetCuts[4] = prodFacetCuts[4];
            betaFacetCuts[5] = prodFacetCuts[5];
            betaFacetCuts[6] = prodFacetCuts[6];
            betaFacetCuts[7] = prodFacetCuts[7];
            betaFacetCuts[8] = prodFacetCuts[8];
            betaFacetCuts[9] = IDiamond.FacetCut({
                facetAddress: address(setters),
                action: IDiamond.FacetCutAction.Add,
                functionSelectors: betaSettersFS()
            });
        }

        vm.startBroadcast(deployerKey);
        DiamondArgs memory args = DiamondArgs({
            owner: deployer,
            init: address(initializer),
            initCalldata: abi.encodeWithSelector(initializer.init.selector)
        });
        IKairos newKairos = IKairos(address(new Diamond(betaFacetCuts, args)));
        {
            uint256 oneBetaDay = 5 * 12; // in seconds
            uint256 oneBetaYear = oneBetaDay * 365;
            uint256 thirtyMinutes = 60 * 30; // in seconds
            BetaSettersFacet(address(newKairos)).setAprAndAuctionDuration({
                newTrancheZero: ONE.div(10).mul(4).div(oneBetaYear),
                newAuctionDuration: thirtyMinutes
            });
        }
        vm.stopBroadcast();

        console.log(address(newKairos));
    }
}
