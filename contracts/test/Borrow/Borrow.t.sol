// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../SetUp.sol";
import "./ComplexBorrow/PreExecFuncs.sol";

// contract TestBorrow is SetUp, ComplexBorrowPreExecFuncs {
//     using RayMath for Ray;
//     using RayMath for uint256;

//     function testSimpleNFTonReceived() public {
//         uint256 tokenId = getTokens();

//         bytes memory data = abi.encode(getOfferArgs(getOffer()));

//         vm.prank(signer);
//         nft.safeTransferFrom(signer, address(kairos), tokenId, data);
//     }

// function testWrongNFTAddress() public {
//     IERC721 wrongNFT = IERC721(address(1));

//     Offer memory offer = Offer({
//         assetToLend: money,
//         loanToValue: 10 ether,
//         duration: 2 weeks,
//         expirationDate: block.timestamp + 3 weeks,
//         collatSpecType: CollatSpecType.Floor,
//         tranche: 0,
//         collatSpecs: abi.encode(FloorSpec({implem: wrongNFT}))
//     });
//     bytes memory data = abi.encode(getOfferArgs(offer));
//     uint256 tokenId = getTokens();

//     vm.startPrank(signer);
//     vm.expectRevert(abi.encodeWithSelector(NFTContractDoesntMatchOfferSpecs.selector, nft, wrongNFT));
//     nft.safeTransferFrom(signer, address(kairos), tokenId, data);
// }

// todo #12 test unknown collat spec type
// }
