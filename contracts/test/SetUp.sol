// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

import "./TestCommons.sol";
import "../interface/IKairos.sol";

contract SetUp is TestCommons, ERC721Holder {
    IKairos internal kairos;

    function setUp() public {
        nftaclp = new Diamond(address(this), address(cut));
        IDiamondCut.FacetCut[] memory facetCuts = getFacetCuts();
        IDiamondCut(address(nftaclp)).diamondCut(
            facetCuts, address(initializer), abi.encodeWithSelector(initializer.init.selector));
        nft = new NFT("Test NFT", "TNFT");
        vm.label(address(nft), "nft");
        nft2 = new NFT("Test NFT2", "TNFT2");
        vm.label(address(nft2), "nft2");
        money = new Money();
        vm.label(address(money), "money");
        money2 = new Money();
        vm.label(address(money2), "money2");
        vm.warp(2 * 365 days);
        kairos = IKairos(address(nftaclp));
    }

    /* solhint-disable-next-line function-max-lines */
    function getFacetCuts() private view returns(IDiamondCut.FacetCut[] memory) {
        IDiamondCut.FacetCut[] memory facetCuts = new IDiamondCut.FacetCut[](9);

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

        facetCuts[6] = IDiamondCut.FacetCut({
            facetAddress: address(auction),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: auctionFS()
        });

        facetCuts[7] = IDiamondCut.FacetCut({
            facetAddress: address(claim),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: claimFS()
        });
        
        /// @dev : this facet is added for test purposes only, do not include in prod
        facetCuts[8] = IDiamondCut.FacetCut({
            facetAddress: address(helper),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: helperFS()
        });

        return facetCuts;
    }

    function helperFS() private pure returns(bytes4[] memory) {
        bytes4[] memory functionSelectors = new bytes4[](1);

        functionSelectors[0] = DCHelperFacet.delegateCall.selector;

        return functionSelectors;
    }
}