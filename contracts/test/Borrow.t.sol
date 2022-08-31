// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "./SetUp.sol";

contract BorrowTest is SetUp {
    function testSimpleBorrow() public {
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
                    collateral: wrongNFT
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

    function getOfferArgs(Offer memory offer) private returns(OfferArgs[] memory){
        OfferArgs[] memory offerArgs = new OfferArgs[](1);
        bytes32 bytesRoot = keccak256(abi.encode(offer));
        bytes32[] memory emptyArray;
        offerArgs[0] = OfferArgs({
            proof: emptyArray,
            root: Root({ root : bytesRoot }),
            signature: getSignature(bytesRoot),
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

    function getSignature(bytes32 bytesRoot) private returns(bytes memory signature){
        Root memory root = Root({root : bytesRoot});
        bytes32 digest = IBorrowFacet(address(nftaclp)).rootDigest(root);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(KEY, digest);
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
                    collateral: nft
                }))
            });
    }

    // todo : test unknown collat spec type
    // todo : test multiple offers used for one NFT
}