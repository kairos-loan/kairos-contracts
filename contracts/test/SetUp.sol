// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "diamond/Diamond.sol";
import "diamond/facets/OwnershipFacet.sol";
import "diamond/facets/DiamondCutFacet.sol";
import "diamond/interfaces/IDiamondCut.sol";
import "diamond/facets/DiamondLoupeFacet.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

import "../Initializer.sol"; 
import "../utils/FuncSelectors.h.sol";
import "../utils/NFT.sol";
import "../utils/Money.sol";
import "../BorrowFacet.sol";
import "../SupplyPositionFacet.sol";
import "./TestCommons.sol";

contract SetUp is TestCommons, ERC721Holder {
    Diamond internal nftaclp;
    Initializer private initializer;
    OwnershipFacet private ownership;
    Money internal money;
    NFT internal nft;

    function setUp() public {
        DiamondCutFacet cut = new DiamondCutFacet();
        nftaclp = new Diamond(address(this), address(cut));
        initializer = new Initializer();
        IDiamondCut.FacetCut[] memory facetCuts = getFacetCuts();
        IDiamondCut(address(nftaclp)).diamondCut(
            facetCuts, address(initializer), abi.encodeWithSelector(initializer.init.selector));
        nft = new NFT("Test NFT", "TNFT");
        money = new Money();
    }

    function getFacetCuts() private returns(IDiamondCut.FacetCut[] memory) {
        IDiamondCut.FacetCut[] memory facetCuts = new IDiamondCut.FacetCut[](4);

        DiamondLoupeFacet loupe = new DiamondLoupeFacet();
        ownership = new OwnershipFacet();
        BorrowFacet borrow = new BorrowFacet();
        SupplyPositionFacet supplyPosition= new SupplyPositionFacet();

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

        facetCuts[2] = IDiamondCut.FacetCut({
            facetAddress: address(borrow),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: borrowFS()
        });

        facetCuts[3] = IDiamondCut.FacetCut({
            facetAddress: address(supplyPosition),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: supplyPositionFS()
        });

        return facetCuts;
    }
}