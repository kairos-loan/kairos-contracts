// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "./SetUp.sol";

contract BorrowTest is SetUp {
    function testSimpleBorrow() public {
        uint256 key = 1;
        address signer = vm.addr(key);
        BorrowFacet.OfferArgs[] memory offerArgs = new BorrowFacet.OfferArgs[](1);
        Offer memory offer = getOffer();
        
        bytes32 bytesRoot = keccak256(abi.encode(offer));
        IBorrowFacet.Root memory root = IBorrowFacet.Root({root : bytesRoot});
        bytes32 digest = IBorrowFacet(address(nftaclp)).rootDigest(root);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, digest);
        bytes memory signature = bytes.concat(r, s, bytes1(v));
        bytes32[] memory emptyArray;
        
        vm.startPrank(signer);

        uint256 tokenId = nft.mintOne();
        money.mint(100 ether);
        money.approve(address(nftaclp), 50 ether);
        offerArgs[0] = BorrowFacet.OfferArgs({
            proof: emptyArray,
            root: Root({ root : bytesRoot }),
            signature: signature,
            amount: 1 ether,
            offer: offer
        });
        bytes memory data = abi.encode(offerArgs);

        nft.safeTransferFrom(signer, address(nftaclp), tokenId, data);
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
                    collateral: nft
                }))
            });
    }

    // function testWrongNFTAddress() public {
    //     bytes memory emptyBytes;
    //     bytes memory data = abi.encode(BorrowFacet.OfferArgs({
    //         offer: Offer({
    //             assetToLend: money,
    //             loanToValue: 1 ether,
    //             duration: 2 weeks,
    //             nonce: 0,
    //             collatSpecType: CollatSpecType.Floor,
    //             tranche: 0,
    //             collatSpecs: abi.encode(FloorSpec({
    //                 collateral: IERC721(address(1))
    //             }))
    //         }),
    //         signature: emptyBytes
    //     }));

    //     vm.expectRevert(abi.encodeWithSelector(
    //         NFTContractDoesntMatchOfferSpecs.selector,
    //         nft,
    //         IERC721(address(1))
    //     ));
    //     nft.safeTransferFrom(address(this), address(nftaclp), 1, data);
    // }

    // todo : test unknown collat spec type
    // todo : test multiple offers used for one NFT
}