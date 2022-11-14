// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../SetUp.sol";
import "../../DataStructure/Objects.sol";
import "./ComplexBorrow/PreExecFuncs.sol";

contract TestBorrow is SetUp {
    using RayMath for Ray;
    using RayMath for uint256;

    function testSimpleNFTonReceived() public {
        uint tokenId = getTokens();

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
            expirationDate: 0,
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
                    expirationDate: 0,
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
                    expirationDate: 0,
                    collatSpecType: CollatSpecType(1),
                    tranche: 0,
                    collatSpecs: abi.encode(NFToken({implem: nft, id: 2}))
                })
            )
        );
        vm.prank(signer);
        nft.safeTransferFrom(signer, address(kairos), tokenId, data);
    }
}
