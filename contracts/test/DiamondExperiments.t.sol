// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";

import "diamond/facets/DiamondCutFacet.sol";
import "../script/experiments/DiamondDeploy.s.sol";
import "diamond/upgradeInitializers/DiamondInit.sol";
import "diamond/facets/DiamondLoupeFacet.sol";
import "diamond/facets/OwnershipFacet.sol";
import "diamond/Diamond.sol";
import "diamond/interfaces/IDiamondCut.sol";
import "../utils/FuncSelectors.h.sol";

bytes32 constant FACETA_STORAGE_POSITION = keccak256("eth.polypus.experiment.facetA");

/* solhint-disable func-visibility */

function facetAStorage() pure returns (AStorage storage a) {
    bytes32 position = FACETA_STORAGE_POSITION;
    /* solhint-disable-next-line no-inline-assembly */
    assembly {
        a.slot := position
    }
}

function aFunctionSelectors() pure returns(bytes4[] memory) {
    bytes4[] memory functionSelectors = new bytes4[](1);
    
    functionSelectors[0] = FacetA.setTheNumberTo2.selector;

    return functionSelectors;
}

function bFunctionSelectors() pure returns(bytes4[] memory) {
    bytes4[] memory functionSelectors = new bytes4[](1);
    
    functionSelectors[0] = FacetB.getTheNumber.selector;

    return functionSelectors;
}

/* solhint-disable enable-visibility */

struct AStorage {
    uint256 number;
}

interface IExperiment {
    function setTheNumberTo2() external;
    function getTheNumber() external view returns(uint256);
}

contract FacetA {
    function setTheNumberTo2() external {
        AStorage storage a = facetAStorage();

        a.number = 2;
    }
}

contract FacetB {
    function getTheNumber() external view returns(uint256) {
        return facetAStorage().number;
    }
}

contract DiamondExperiments is Test {
    // inspired by the deploy process of https://github.com/mudgen/diamond-1-hardhat

    Diamond private diamond;
    DiamondInit private diamondInit;
    OwnershipFacet private ownership;

    function setUp() public {
        // 1. Deploy Diamond cut facet
        DiamondCutFacet cut = new DiamondCutFacet();

        // 2. Deploy the diamond setting owner & diamond cut facet
        diamond = new Diamond(address(this), address(cut));

        // 3. Deploy DiamondInit (func that will be delegatecall in future upgrades)
        diamondInit = new DiamondInit();

        // 4. Deploy Facets
        DiamondLoupeFacet loupe = new DiamondLoupeFacet();
        ownership = new OwnershipFacet();

        // 6. Diamond is upgarded with facets
        IDiamondCut.FacetCut[] memory facetCuts = new IDiamondCut.FacetCut[](2);

        facetCuts[0] = IDiamondCut.FacetCut({
            facetAddress: address(loupe),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: loupeFS()
        });

        facetCuts[1] = IDiamondCut.FacetCut({
            facetAddress: address(ownership),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: ownershipFS()
        });

        IDiamondCut(address(diamond)).diamondCut(
            facetCuts, address(diamondInit), abi.encodeWithSelector(diamondInit.init.selector));
    }

    function testUpgradeAndInteract() public {
        IDiamondCut.FacetCut[] memory facetCuts = new IDiamondCut.FacetCut[](2);

        FacetA facetA = new FacetA();
        FacetB facetB = new FacetB();

        facetCuts[0] = IDiamondCut.FacetCut({
            facetAddress: address(facetA),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: aFunctionSelectors()
        });

        facetCuts[1] = IDiamondCut.FacetCut({
            facetAddress: address(facetB),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: bFunctionSelectors()
        });

        IDiamondCut(address(diamond)).diamondCut(
            facetCuts, address(diamondInit), abi.encodeWithSelector(diamondInit.init.selector));

        IExperiment interactiveDiamond = IExperiment(address(diamond));
        
        assertEq(interactiveDiamond.getTheNumber(), 0);
        interactiveDiamond.setTheNumberTo2();
        assertEq(interactiveDiamond.getTheNumber(), 2);
    }
}
