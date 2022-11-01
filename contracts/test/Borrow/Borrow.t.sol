// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../SetUp.sol";

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
                nonce: 0,
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

    struct Offer1 {
        IERC20 assetToLend;
        uint256 loanToValue;
        uint256 duration;
        uint256 nonce;
        uint8 collatSpecType;
        uint256 tranche;
        bytes collatSpecs;
    }

    function testUnkownCollatSpec() public {
        uint256 tokenId = getTokens(signer);

        vm.startPrank(signer);

        bytes memory data = abi.encode(
            getOfferArgs(
                Offer({
            assetToLend: money,
            loanToValue: 10 ether,
            duration: 2 weeks,
            nonce: 0,
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



    money.mint(2 ether);
        money.approve(address(this), 2 ether);


        Offer memory offer1 = Offer({
        assetToLend: money,
        loanToValue: 10 ether,
        duration: 2 weeks,
        nonce: 0,
        collatSpecType: CollatSpecType.Floor,
        tranche: 0,
        collatSpecs: abi.encode(FloorSpec({
        implem: nft
        }))
        });

        Offer memory offer2 = Offer({
        assetToLend: money,
        loanToValue: 1 ether,
        duration: 2 weeks,
        nonce: 0,
        collatSpecType: CollatSpecType.Floor,
        tranche: 0,
        collatSpecs: abi.encode(FloorSpec({
        implem: nft2
        }))
        });

        OfferArgs[] memory offerArgsTest = new OfferArgs[](1);
        Root memory root1 = Root({root: keccak256(abi.encode(offer1))});
        bytes32[] memory emptyArray;
        offerArgsTest[0] = OfferArgs({
        proof: emptyArray,
        root:root1,
        signature: getSignature(root1),
        amount: 10 ether,
        offer:offer1
    });

        Root memory root2 = Root({root: keccak256(abi.encode(offer2))});

    offerArgsTest[1] = OfferArgs({
        proof: emptyArray,
        root:root2,
        signature: getSignature(root2),
        amount: 10 ether,
        offer:offer2
        });

        vm.prank(address(2));

        console.log(money.balanceOf(address(this)));

        //Borrow one nft
        //Kairos.borrow(offerArgsTest);






        //Repay
        //Check offers balance



    }
}