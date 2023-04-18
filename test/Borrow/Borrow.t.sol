// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {BadCollateral, RequestedAmountIsUnderMinimum, ShareMatchedIsTooLow} from "../../src/DataStructure/Errors.sol";
import {BorrowArg, NFToken, Offer, OfferArg} from "../../src/DataStructure/Objects.sol";
import {External} from "../Commons/External.sol";
import {Loan, Provision} from "../../src/DataStructure/Storage.sol";
import {Ray} from "../../src/DataStructure/Objects.sol";
import {RayMath} from "../../src/utils/RayMath.sol";

contract TestBorrow is External {
    using RayMath for Ray;
    using RayMath for uint256;

    function testSimpleNFTonReceived() public {
        getFlooz(signer, money, getOfferArg(getOffer()).amount);
        uint256 tokenId = nft.mintOneTo(BORROWER);
        assertEq(nft.balanceOf(BORROWER), 1);

        bytes memory data = abi.encode(getOfferArgs(getOffer()));

        vm.prank(BORROWER);
        nft.safeTransferFrom(BORROWER, address(kairos), tokenId, data);
        assertEq(nft.balanceOf(BORROWER), 0);
        assertEq(nft.ownerOf(tokenId), address(kairos));
        assertEq(money.balanceOf(BORROWER), getOfferArg(getOffer()).amount);
        assertEq(kairos.getLoan(1).borrower, BORROWER);
        assertEq(address(kairos.getLoan(1).collateral.implem), address(nft));
    }

    function testWrongNFTAddress() public {
        Offer memory offer = getOffer();
        OfferArg[] memory offArgs = getOfferArgs(offer);
        bytes memory data = abi.encode(offArgs);
        uint256 tokenId = nft2.mintOneTo(BORROWER);

        vm.startPrank(BORROWER);
        vm.expectRevert(
            abi.encodeWithSelector(BadCollateral.selector, offer, NFToken({implem: nft2, id: tokenId}))
        );
        nft2.safeTransferFrom(BORROWER, address(kairos), tokenId, data);
    }

    function testNullBorrowAmount() public {
        getJpeg(BORROWER, nft);
        BorrowArg[] memory borrowArgs = getBorrowArgs();
        borrowArgs[0].args[0].amount = 0;

        vm.prank(BORROWER);
        vm.expectRevert(
            abi.encodeWithSelector(
                RequestedAmountIsUnderMinimum.selector,
                borrowArgs[0].args[0].offer,
                0,
                1 ether / 100
            )
        );
        kairos.borrow(borrowArgs);
    }

    function testShareMatchedTooLow() public {
        vm.prank(OWNER);
        kairos.setBorrowAmountPerOfferLowerBound(money, 1);
        getJpeg(BORROWER, nft);
        BorrowArg[] memory borrowArgs = getBorrowArgs();
        borrowArgs[0].args[0].amount = 2;
        vm.prank(BORROWER);
        vm.expectRevert(
            abi.encodeWithSelector(
                ShareMatchedIsTooLow.selector,
                borrowArgs[0].args[0].offer,
                2
            )
        );
        kairos.borrow(borrowArgs);

    }

    function testSimpleBorrow() public {
        borrowNTimes(1);
    }

    function testMultipleBorrow() public {
        borrowNTimes(12);
    }

    function borrowNTimes(uint256 nbOfLoans) internal {
        BorrowArg[] memory borrowArgs = new BorrowArg[](nbOfLoans);
        Offer memory offer;
        uint256 currentTokenId;

        getFlooz(signer, money, nbOfLoans * getOfferArg().amount);

        for (uint256 i = 0; i < nbOfLoans; i++) {
            OfferArg[] memory offerArgs = new OfferArg[](1);
            currentTokenId = getJpeg(BORROWER, nft);
            offer = getOffer();
            offer.collateral.id = currentTokenId;
            offerArgs[0] = OfferArg({
                signature: getSignature(offer),
                amount: getOfferArg().amount,
                offer: offer
            });
            borrowArgs[i] = BorrowArg({nft: NFToken({id: currentTokenId, implem: nft}), args: offerArgs});
        }

        vm.prank(BORROWER);
        kairos.borrow(borrowArgs);

        assertEq(nft.balanceOf(BORROWER), 0);
        assertEq(money.balanceOf(signer), 0);
        assertEq(money.balanceOf(BORROWER), nbOfLoans * getOfferArg().amount);
        assertEq(nft.balanceOf(address(kairos)), nbOfLoans);
        for (uint256 i = 0; i < nbOfLoans; i++) {
            assertEq(nft.ownerOf(i + 1), address(kairos));
        }
    }
}
