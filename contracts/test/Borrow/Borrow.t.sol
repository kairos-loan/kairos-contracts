// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../Commons/SetUp.sol";

contract TestBorrow is SetUp {
    using RayMath for Ray;
    using RayMath for uint256;

    function testSimpleNFTonReceived() public {
        uint256 tokenId = getTokens(signer);

        bytes memory data = abi.encode(getOfferArgs(getOffer()));

        vm.prank(signer);
        nft.safeTransferFrom(signer, address(kairos), tokenId, data);
    }

    function testWrongNFTAddress() public {
        IERC721 wrongNFT = IERC721(address(1));

        Offer memory offer = getOffer();
        offer.collateral.implem = wrongNFT;

        bytes memory data = abi.encode(getOfferArgs(offer));
        uint256 tokenId = getTokens(signer);

        vm.startPrank(signer);
        vm.expectRevert(abi.encodeWithSelector(NFTContractDoesntMatchOfferSpecs.selector, nft, wrongNFT));
        nft.safeTransferFrom(signer, address(kairos), tokenId, data);
    }
}
