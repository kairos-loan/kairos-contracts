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

    function testSimpleBorrow() public {
        borrowNTimes(1);
    }

    function testMultipleBorrow() public {
        borrowNTimes(12);
    }

    function borrowNTimes(uint8 nbOfLoans) internal {
        BorrowArgs[] memory borrowArgs = new BorrowArgs[](nbOfLoans);
        Offer memory offer;
        uint256 currentTokenId;

        getFlooz(signer, money, nbOfLoans * getOfferArg().amount);

        for (uint8 i; i < nbOfLoans; i++) {
            OfferArgs[] memory offerArgs = new OfferArgs[](1);
            currentTokenId = getJpeg(BORROWER, nft);
            offer = getOffer();
            offer.collateral.id = currentTokenId;
            offerArgs[0] = OfferArgs({
                signature: getSignature(offer),
                amount: getOfferArg().amount,
                offer: offer
            });
            borrowArgs[i] = BorrowArgs({nft: NFToken({id: currentTokenId, implem: nft}), args: offerArgs});
        }

        vm.prank(BORROWER);
        kairos.borrow(borrowArgs);

        assertEq(nft.balanceOf(BORROWER), 0);
        assertEq(money.balanceOf(signer), 0);
        assertEq(money.balanceOf(BORROWER), nbOfLoans * getOfferArg().amount);
        assertEq(nft.balanceOf(address(kairos)), nbOfLoans);
        for (uint8 i; i < nbOfLoans; i++) {
            assertEq(nft.ownerOf(i + 1), address(kairos));
        }
    }
}
