// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../Commons/External.sol";

contract TestBorrow is External {
    using RayMath for Ray;
    using RayMath for uint256;

    function testSimpleNFTonReceived() public {
        getFlooz(signer, money, getOfferArg(getOffer()).amount);
        uint256 tokenId = nft.mintOneTo(BORROWER);

        bytes memory data = abi.encode(getOfferArgs(getOffer()));

        vm.prank(BORROWER);
        nft.safeTransferFrom(BORROWER, address(kairos), tokenId, data);
    }

    function testWrongNFTAddress() public {
        Offer memory offer = getOffer();
        OfferArgs[] memory offArgs = getOfferArgs(offer);
        bytes memory data = abi.encode(offArgs);
        uint256 tokenId = nft2.mintOneTo(BORROWER);

        vm.startPrank(BORROWER);
        vm.expectRevert(
            abi.encodeWithSelector(BadCollateral.selector, offer, NFToken({implem: nft2, id: tokenId}))
        );
        nft2.safeTransferFrom(BORROWER, address(kairos), tokenId, data);
    }
}
