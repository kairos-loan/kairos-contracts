// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "./SetUp.sol";

contract BorrowTest is SetUp {
    function testSimpleBorrow() public {
        bytes memory emptyBytes;
        bytes memory data = abi.encode(Borrow.BorrowArgs({
            offer: Offer({
                assetToLend: money,
                loanToValue: 1 ether,
                duration: 2 weeks,
                nonce: 0,
                collatSpecType: CollatSpecType.Floor,
                tranche: 0,
                collatSpecs: abi.encode(FloorSpec({
                    collateral: nft
                }))
            }),
            signature: emptyBytes
        }));

        nft.safeTransferFrom(address(this), address(nftaclp), 1, data);
    }
}