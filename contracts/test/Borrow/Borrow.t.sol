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
    // todo : test multiple offers used for one NFT
}