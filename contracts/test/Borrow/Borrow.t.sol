// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "../SetUp.sol";

contract TestBorrow is SetUp {
    function testSimpleNFTonReceived() public {
        uint256 tokenId = getTokens(signer);

        vm.startPrank(signer);

        bytes memory data = abi.encode(getOfferArgs(getOffer()));

        nft.safeTransferFrom(signer, address(nftaclp), tokenId, data);
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
        nft.safeTransferFrom(signer, address(nftaclp), tokenId, data);
    }

    // should pass in a scenario as complex as possible
    // should borrow from 2 NFTs, one of which should borrow from 2 offers of different suppliers
    // use different cryptos for the 2 NFTs
    // NFT 1 : from collec1 with money1 with 2 suppliers
    // NFT 2 : from collec2 with money2 with 1 supplier
    // NFT 1 : 25% from supp1 at 2 eth valuation, 75% from supp2 at 1 eth val 
    function testComplexBorrow() public {
        BorrowArgs memory bargs1;
        BorrowArgs memory bargs2;
        OfferArgs memory oargs1;
        OfferArgs memory oargs2;
        OfferArgs memory oargs3;
        Offer memory signer1Offer1;
        Offer memory signer1Offer2;
        Offer memory signer2Offer;

        vm.prank(signer);
        money.mint(2 ether);
        vm.prank(signer);
        money.approve(address(nftaclp), 2 ether);

        vm.prank(signer2);
        money.mint(2 ether);
        vm.prank(signer2);
        money.approve(address(nftaclp), 2 ether);

        vm.prank(signer);
        money2.mint(2 ether);
        vm.prank(signer);
        money2.approve(address(nftaclp), 2 ether);

        nft.approve(address(nftaclp), 1);
        nft2.approve(address(nftaclp), 1);

        signer1Offer1 = Offer({
            assetToLend: money,
            loanToValue: 2 ether,
            duration: 2 weeks,
            nonce: 0,
            collatSpecType: CollatSpecType.Single,
            tranche: 0,
            collatSpecs: abi.encode(NFToken({
                implem: nft,
                id: 1
            }))
        });

        signer1Offer2 = Offer({
            assetToLend: money2,
            loanToValue: 2 ether,
            duration: 4 weeks,
            nonce: 0,
            collatSpecType: CollatSpecType.Single,
            tranche: 0,
            collatSpecs: abi.encode(NFToken({
                implem: nft2,
                id: 1
            }))
        });

        signer2Offer = Offer({
            assetToLend: money2,
            loanToValue: 1 ether,
            duration: 1 weeks,
            nonce: 0,
            collatSpecType: CollatSpecType.Floor,
            tranche: 0,
            collatSpecs: abi.encode(FloorSpec({
                implem: nft
            }))
        });

        {
            bytes32 hashSign1Off1 = keccak256(abi.encode(signer1Offer1));
            bytes32 hashSign1Off2 = keccak256(abi.encode(signer1Offer2));
            bytes32 hashSign2Off = keccak256(abi.encode(signer2Offer));
            Root memory rootSign1 = Root({root: keccak256(abi.encode(hashSign1Off1, hashSign1Off2))});
            Root memory rootSign2 = Root({root: hashSign2Off});
            // hashSign1Off1 < hashSign1Off2 = true
            bytes32[] memory proofSign1Off1 = new bytes32[](1);
            proofSign1Off1[0] = hashSign1Off2;
            bytes32[] memory proofSign1Off2 = new bytes32[](1);
            proofSign1Off2[0] = hashSign1Off1;
            bytes32[] memory proofSign2Off;
            oargs1 = OfferArgs({
                proof: proofSign1Off1,
                root: rootSign1,
                signature: getSignature(rootSign1),
                amount: 1 ether / 2, // 25%
                offer: signer1Offer1
            });

            oargs2 = OfferArgs({
                proof: proofSign2Off,
                root: rootSign2,
                signature: getSignature2(rootSign2),
                amount: 3 ether / 4, // 75%
                offer: signer2Offer
            });

            oargs3 = OfferArgs({
                proof: proofSign1Off2,
                root: rootSign1,
                signature: getSignature2(rootSign1),
                amount: 2 ether, // 100%
                offer: signer1Offer2
            });
        }
        {
            OfferArgs[] memory offerArgs1 = new OfferArgs[](2);
            offerArgs1[0] = oargs1;
            offerArgs1[1] = oargs2;
            OfferArgs[] memory offerArgs2 = new OfferArgs[](1);
            offerArgs2[0] = oargs3;

            bargs1 = BorrowArgs({
                nft: NFToken({
                    implem: nft,
                    id: 1
                }),
                args: offerArgs1
            });
            
            bargs2 = BorrowArgs({
                nft: NFToken({
                    implem: nft2,
                    id: 1
                }),
                args: offerArgs2
            });
        }
        {
            BorrowArgs[] memory batchbargs = new BorrowArgs[](2);
            batchbargs[0] = bargs1;
            batchbargs[1] = bargs2;

            IBorrowFacet(address(nftaclp)).borrow(batchbargs);
        }
    }

    // helpers

    function getOfferArgs(Offer memory offer) private returns(OfferArgs[] memory){
        OfferArgs[] memory offerArgs = new OfferArgs[](1);
        Root memory root = Root({root: keccak256(abi.encode(offer))});
        bytes32[] memory emptyArray;
        offerArgs[0] = OfferArgs({
            proof: emptyArray,
            root: root,
            signature: getSignature(root),
            amount: 1 ether,
            offer: offer
        });
        return offerArgs;
    }

    function getTokens(address receiver) private returns(uint256 tokenId){
        vm.startPrank(receiver);

        tokenId = nft.mintOne();
        money.mint(100 ether);
        money.approve(address(nftaclp), 100 ether);

        vm.stopPrank();   
    }

    function getSignature(Root memory root) private returns(bytes memory signature){
        bytes32 digest = IBorrowFacet(address(nftaclp)).rootDigest(root);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(KEY, digest);
        signature = bytes.concat(r, s, bytes1(v));
    }

    function getSignature2(Root memory root) private returns(bytes memory signature){
        bytes32 digest = IBorrowFacet(address(nftaclp)).rootDigest(root);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(KEY2, digest);
        signature = bytes.concat(r, s, bytes1(v));
    }

    function getOffer() private view returns(Offer memory){
        return Offer({
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
    }

    // todo : test unknown collat spec type
    // todo : test multiple offers used for one NFT
}