// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

import "./TestCommons.sol";

contract SetUp is TestCommons, ERC721Holder {
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

    function getFacetCuts() private returns(IDiamondCut.FacetCut[] memory) {
        IDiamondCut.FacetCut[] memory facetCuts = new IDiamondCut.FacetCut[](6);

        // todo : won't work if the borrow facet isn't deployed here, still need to figurate why
        borrow = new BorrowFacet();

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

        facetCuts[5] = IDiamondCut.FacetCut({
            facetAddress: address(repay),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: repayFS()
        });

        return facetCuts;
    }
}