// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../Borrow.t.sol";
import {External} from "kmain-contracts/test/Commons/External.sol";
import "kmain-contracts/DataStructure/Global.sol";

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
        getFlooz(signer, money, 2 ether);
        getFlooz(signer2, money, 2 ether);
        getFlooz(signer, money2, 2 ether);

        getJpeg(BORROWER, nft);
        getJpeg(BORROWER, nft2);
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
            collateral: NFToken({implem: nft, id: 1})
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
