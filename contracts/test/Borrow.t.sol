// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "./SetUp.sol";

contract BorrowTest is SetUp {
    // struct myCustomOffer

    function testSimpleBorrow() public {
        BorrowFacet.OfferArgs[] memory offerArgs = new BorrowFacet.OfferArgs[](1);
        offerArgs[0] = BorrowFacet.OfferArgs({
            proof: ,
            root: ,
            signature: ,
            amount: ,
            offer: Offer({
                assetToLend: money,
                loanToValue: 1 ether,
                duration: 2 weeks,
                nonce: 0,
                collatSpecType: CollatSpecType.Floor,
                tranche: 0,
                collatSpecs: abi.encode(FloorSpec({
                    collateral: nft
                })
            })
        });
        bytes memory data = abi.encode(offerArgs);
        nft.safeTransferFrom(address(this), address(nftaclp), 1, data);
    }

    function testWrongNFTAddress() public {
        bytes memory emptyBytes;
        bytes memory data = abi.encode(BorrowFacet.OfferArgs({
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

    function testSig() public {
        uint256 aPrivateKey = uint256(0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa);
        console.log("signer", vm.addr(aPrivateKey));
        IBorrow.Test memory testtest = IBorrow.Test(12);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(aPrivateKey, IBorrow(address(nftaclp)).getDigest(testtest));
        console.log("found ", IBorrow(address(nftaclp)).hereToTest(testtest, bytes.concat(r, s, bytes1(v))));
    }
}