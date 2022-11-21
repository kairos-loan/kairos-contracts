// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../SetUp.sol";
import "../../DataStructure/Objects.sol";
import "./ComplexBorrow/PreExecFuncs.sol";

contract TestBorrow is SetUp, ComplexBorrowPreExecFuncs {
    using RayMath for Ray;
    using RayMath for uint256;

    function testSimpleNFTonReceived() public {
        uint256 tokenId = getTokens();

        bytes memory data = abi.encode(getOfferArgs(getOffer()));

        vm.prank(signer);
        nft.safeTransferFrom(signer, address(kairos), tokenId, data);
    }

    function testWrongNFTAddress() public {
        IERC721 wrongNFT = IERC721(address(1));

        Offer memory offer = Offer({
            assetToLend: money,
            loanToValue: 10 ether,
            duration: 2 weeks,
            expirationDate: block.timestamp + 3 weeks,
            collatSpecType: CollatSpecType.Floor,
            tranche: 0,
            collatSpecs: abi.encode(FloorSpec({implem: wrongNFT}))
        });
        bytes memory data = abi.encode(getOfferArgs(offer));
        uint256 tokenId = getTokens();

        vm.startPrank(signer);
        vm.expectRevert(abi.encodeWithSelector(NFTContractDoesntMatchOfferSpecs.selector, nft, wrongNFT));
        nft.safeTransferFrom(signer, address(kairos), tokenId, data);
    }

    // test unknown collat spec type
    function testUnkownCollatSpec0() public {
        uint256 tokenId = getTokens();

        bytes memory data = abi.encode(
            getOfferArgs(
                Offer({
                    assetToLend: money,
                    loanToValue: 10 ether,
                    duration: 2 weeks,
                    expirationDate: block.timestamp + 3 weeks,
                    collatSpecType: CollatSpecType(0),
                    tranche: 0,
                    collatSpecs: abi.encode(FloorSpec({implem: nft}))
                })
            )
        );
        vm.prank(signer);
        nft.safeTransferFrom(signer, address(kairos), tokenId, data);
    }

    //Uint 8 -> Coll
    function testUnkownCollatSpec1() public {
        uint256 tokenId = getTokens();

        bytes memory data = abi.encode(
            getOfferArgs(
                Offer({
                    assetToLend: money,
                    loanToValue: 10 ether,
                    duration: 2 weeks,
                    expirationDate: block.timestamp + 3 weeks,
                    collatSpecType: CollatSpecType(1),
                    tranche: 0,
                    collatSpecs: abi.encode(NFToken({implem: nft, id: 2}))
                })
            )
        );
        vm.prank(signer);
        nft.safeTransferFrom(signer, address(kairos), tokenId, data);
    }

    // todo : test multiple offers used for one NFT
    function testMultipleOffersForOneNft() public {
        ComplexBorrowData memory complexBorrowData;

        prepareSigners();

        complexBorrowData = initOffers(complexBorrowData);
        complexBorrowData = initOfferArgs(complexBorrowData);

        OfferArgs[] memory offerArgs = new OfferArgs[](2);
        offerArgs[0] = complexBorrowData.oargs1;
        offerArgs[1] = complexBorrowData.oargs2;

        complexBorrowData.bargs1 = BorrowArgs({nft: NFToken({implem: nft, id: 1}), args: offerArgs});

        BorrowArgs[] memory batchbargs = new BorrowArgs[](1);
        batchbargs[0] = complexBorrowData.bargs1;

        kairos.borrow(batchbargs);
        assertEq(kairos.balanceOf(signer2), 1);
        Provision memory supp1pos1 = kairos.position(1);
        assertEq(supp1pos1.amount, 1 ether / 2);
        assertEq(supp1pos1.share, ONE.div(4));
    }
}
