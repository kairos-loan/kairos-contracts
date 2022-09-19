// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

import "./TestCommons.sol";
import "../interface/IKairos.sol";

contract SetUp is TestCommons, ERC721Holder {
    IKairos internal kairos;

    function setUp() public {
        bytes memory emptyBytes;
        nftaclp = new Diamond(address(this), address(cut));
        IDiamondCut(address(nftaclp)).diamondCut(
            testFacetCuts(), address(0), emptyBytes);
        IDiamondCut(address(nftaclp)).diamondCut(
            getFacetCuts(), address(initializer), abi.encodeWithSelector(initializer.init.selector));
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

    function testFacetCuts() internal view returns(IDiamondCut.FacetCut[] memory) {
        IDiamondCut.FacetCut[] memory facetCuts = new IDiamondCut.FacetCut[](1);
                
        facetCuts[0] = IDiamondCut.FacetCut({
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