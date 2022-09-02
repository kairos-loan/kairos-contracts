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
import "../ProtocolFacet.sol";
import "../SupplyPositionFacet.sol";
import "./TestCommons.sol";

contract SetUp is TestCommons, ERC721Holder {
    Diamond internal nftaclp;
    Initializer private initializer;
    DiamondCutFacet private cut;
    OwnershipFacet private ownership;
    DiamondLoupeFacet private loupe;
    BorrowFacet private borrow;
    SupplyPositionFacet private supplyPosition;
    ProtocolFacet private protocol;
    Money internal money;
    Money internal money2;
    NFT internal nft;
    NFT internal nft2;

    constructor() {
        cut = new DiamondCutFacet();
        loupe = new DiamondLoupeFacet();
        ownership = new OwnershipFacet();
        borrow = new BorrowFacet();
        supplyPosition = new SupplyPositionFacet();
        protocol = new ProtocolFacet();
        initializer = new Initializer();
    }

    function setUp() public {
        nftaclp = new Diamond(address(this), address(cut));
        IDiamondCut.FacetCut[] memory facetCuts = getFacetCuts();
        IDiamondCut(address(nftaclp)).diamondCut(
            facetCuts, address(initializer), abi.encodeWithSelector(initializer.init.selector));
        nft = new NFT("Test NFT", "TNFT");
        vm.label(address(nft), "nft");
        nft2 = new NFT("Test NFT2", "TNFT2");
        vm.label(address(nft), "nft2");
        money = new Money();
        vm.label(address(money), "money");
        money2 = new Money();
        vm.label(address(money2), "money2");
    }

    function getFacetCuts() private view returns(IDiamondCut.FacetCut[] memory) {
        IDiamondCut.FacetCut[] memory facetCuts = new IDiamondCut.FacetCut[](5);

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

        facetCuts[4] = IDiamondCut.FacetCut({
            facetAddress: address(protocol),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: protoFS()
        });

        return facetCuts;
    }
}