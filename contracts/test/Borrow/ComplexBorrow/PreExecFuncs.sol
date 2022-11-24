// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../Borrow.t.sol";
import {External} from "contracts/test/Commons/External.sol";
import "contracts/DataStructure/Global.sol";

struct ComplexBorrowData {
    BorrowArgs bargs1;
    BorrowArgs bargs2;
    OfferArgs oargs1;
    OfferArgs oargs2;
    OfferArgs oargs3;
    Offer signer1Offer1;
    Offer signer1Offer2;
    Offer signer2Offer;
    uint256 m1InitialBalance;
    uint256 m2InitialBalance;
}

contract ComplexBorrowPreExecFuncs is External {
    function prepareSigners() internal {
        vm.prank(signer);
        money.mint(2 ether);
        vm.prank(signer);
        money.approve(address(kairos), 2 ether);

        vm.prank(signer2);
        money.mint(2 ether);
        vm.prank(signer2);
        money.approve(address(kairos), 2 ether);

        vm.prank(signer);
        money2.mint(2 ether);
        vm.prank(signer);
        money2.approve(address(kairos), 2 ether);

        nft.approve(address(kairos), 1);
        nft2.approve(address(kairos), 1);
    }

    function initOfferArgs(ComplexBorrowData memory d) internal returns (ComplexBorrowData memory) {
        d.oargs1 = OfferArgs({
            signature: getSignature(d.signer1Offer1),
            amount: 1 ether / 2, // 25%
            offer: d.signer1Offer1
        });
        d.oargs2 = OfferArgs({
            signature: getSignature2(d.signer2Offer),
            amount: 3 ether / 4, // 75%
            offer: d.signer2Offer
        });
        d.oargs3 = OfferArgs({
            signature: getSignature(d.signer1Offer2),
            amount: 1 ether, // 50%
            offer: d.signer1Offer2
        });

        return d;
    }

    function initOffers(ComplexBorrowData memory d) internal view returns (ComplexBorrowData memory) {
        d.signer1Offer1 = Offer({
            assetToLend: money,
            loanToValue: 2 ether,
            duration: 2 weeks,
            expirationDate: block.timestamp + 1,
            tranche: 0,
            collateral: NFToken({implem: nft2, id: 1})
        });
        d.signer1Offer2 = Offer({
            assetToLend: money2,
            loanToValue: 2 ether,
            duration: 4 weeks,
            expirationDate: block.timestamp + 1 days,
            tranche: 0,
            collateral: NFToken({implem: nft2, id: 1})
        });

        d.signer2Offer = Offer({
            assetToLend: money,
            loanToValue: 1 ether,
            duration: 1 weeks,
            expirationDate: block.timestamp + 1 hours,
            tranche: 0,
            collateral: NFToken({implem: nft, id: 1})
        });

        return d;
    }

    function initBorrowArgs(ComplexBorrowData memory d) internal view returns (ComplexBorrowData memory) {
        OfferArgs[] memory offerArgs1 = new OfferArgs[](2);
        offerArgs1[0] = d.oargs1;
        offerArgs1[1] = d.oargs2;
        OfferArgs[] memory offerArgs2 = new OfferArgs[](1);
        offerArgs2[0] = d.oargs3;

        d.bargs1 = BorrowArgs({nft: NFToken({implem: nft, id: 1}), args: offerArgs1});

        d.bargs2 = BorrowArgs({nft: NFToken({implem: nft2, id: 1}), args: offerArgs2});

        return d;
    }
}
