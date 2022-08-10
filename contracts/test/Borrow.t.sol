// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "./SetUp.sol";

contract BorrowTest is SetUp {
    // struct myCustomOffer

    function testSimpleBorrow() public {
        bytes memory emptyBytes;
        bytes memory data = abi.encode(Borrow.BorrowArgs({
            offer: Offer({
                assetToLend: money,
                loanToValue: 1 ether,
                duration: 2 weeks,
                nonce: 0,
                collatSpecType: CollatSpecType.Floor,
                tranche: 0,
                collatSpecs: abi.encode(FloorSpec({
                    collateral: nft
                }))
            }),
            signature: emptyBytes
        }));

        nft.safeTransferFrom(address(this), address(nftaclp), 1, data);
    }

    function testWrongNFTAddress() public {
        bytes memory emptyBytes;
        bytes memory data = abi.encode(Borrow.BorrowArgs({
            offer: Offer({
                assetToLend: money,
                loanToValue: 1 ether,
                duration: 2 weeks,
                nonce: 0,
                collatSpecType: CollatSpecType.Floor,
                tranche: 0,
                collatSpecs: abi.encode(FloorSpec({
                    collateral: IERC721(address(1))
                }))
            }),
            signature: emptyBytes
        }));

        vm.expectRevert(abi.encodeWithSelector(
            NFTContractDoesntMatchOfferSpecs.selector,
            nft,
            IERC721(address(1))
        ));
        nft.safeTransferFrom(address(this), address(nftaclp), 1, data);
    }

    // todo : test unknown collat spec type
}