// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../SetUp.sol";
import "../../DataStructure/Objects.sol";

contract TestBorrow is SetUp {
    using RayMath for Ray;
    using RayMath for uint256;

    function testSimpleNFTonReceived() public {
        uint256 tokenId = getTokens(signer);

        vm.startPrank(signer);

        bytes memory data = abi.encode(getOfferArgs(getOffer()));

        nft.safeTransferFrom(signer, address(kairos), tokenId, data);
    }

    function testWrongNFTAddress() public {
        IERC721 wrongNFT = IERC721(address(1));

        Offer memory offer = Offer({
                assetToLend: money,
                loanToValue: 10 ether,
                duration: 2 weeks,
                expirationDate: 0,
                collatSpecType: CollatSpecType.Floor,
                tranche: 0,
                collatSpecs: abi.encode(FloorSpec({
                    implem: wrongNFT
                }))
            });
        bytes memory data = abi.encode(getOfferArgs(offer));
        uint256 tokenId = getTokens(signer);

        vm.startPrank(signer);
        vm.expectRevert(abi.encodeWithSelector(
            NFTContractDoesntMatchOfferSpecs.selector,
            nft,
            wrongNFT
        ));
        nft.safeTransferFrom(signer, address(kairos), tokenId, data);
    }

    // todo : test unknown collat spec type


    function testUnkownCollatSpec() public {
        uint256 tokenId = getTokens(signer);

        vm.startPrank(signer);

        bytes memory data = abi.encode(
            getOfferArgs(
                Offer({
            assetToLend: money,
            loanToValue: 10 ether,
            duration: 2 weeks,
            expirationDate: 0,
            collatSpecType: CollatSpecType.Floor,
            tranche: 0,
            collatSpecs: abi.encode(FloorSpec({
            implem: nft
            }))
        }))
        );

        nft.safeTransferFrom(signer, address(kairos), tokenId, data);
    }



    // todo : test multiple offers used for one NFT
    function testMultipleOffersForOneNft()public{

        uint x=3;

        //Generate 2 offers

        uint token = getTokens(signer);

        NFToken memory Nft =NFToken({
            implem:nft,
            id: token
        });

        Offer memory offer1 = getOffer();
        Offer memory offer2 = getOffer();

        OfferArgs[] memory offerArg1 = getOfferArgs(offer1);
        OfferArgs[] memory offerArg2 = getOfferArgs(offer2);

        BorrowArgs[] memory borrowArgs = new BorrowArgs[](1);


        borrowArgs[0] = BorrowArgs({
            nft:Nft,
            args: offerArg1
        });

        borrowArgs[1] = BorrowArgs({
            nft : Nft,
            args : offerArg2
        });

        kairos.borrow(borrowArgs);


    }
}