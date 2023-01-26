// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {BorrowArgs, NFToken, Offer, OfferArgs} from "../../../src/DataStructure/Objects.sol";
import {External} from "../../Commons/External.sol";
import {NFT} from "../../../src/mock/NFT.sol";

struct ComplexBorrowData {
    BorrowArgs bargs;
    OfferArgs oargs1;
    OfferArgs oargs2;
    Offer signer1Offer;
    Offer signer2Offer;
    uint256 m1InitialBalance;
    uint256 m2InitialBalance;
}

contract ComplexBorrowPreExecFuncs is External {
    function prepareSigners() internal {
        getFlooz(signer, money, 10 ether);
        getFlooz(signer2, money, 10 ether);

        getFlooz(BORROWER, money, 10 ether);
        getFlooz(address(this), money, 10 ether);

        getJpeg(BORROWER, nft);
    }

    function initOfferArgs(
        ComplexBorrowData memory d,
        uint256 oargs1Amount,
        uint256 oargs2Amount
    ) internal returns (ComplexBorrowData memory) {
        d.oargs1 = OfferArgs({
            signature: getSignature(d.signer1Offer),
            amount: oargs1Amount,
            offer: d.signer1Offer
        });
        d.oargs2 = OfferArgs({
            signature: getSignature2(d.signer2Offer),
            amount: oargs2Amount,
            offer: d.signer2Offer
        });
        return d;
    }

    function initOffers(
        ComplexBorrowData memory d,
        uint256 ltv1,
        uint256 ltv2
    ) internal view returns (ComplexBorrowData memory) {
        d.signer1Offer = Offer({
            assetToLend: money,
            loanToValue: ltv1,
            duration: 4 weeks,
            expirationDate: block.timestamp + 1 hours,
            tranche: 0,
            collateral: NFToken({implem: nft, id: 1})
        });

        d.signer2Offer = Offer({
            assetToLend: money,
            loanToValue: ltv2,
            duration: 4 weeks,
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

        d.bargs = BorrowArgs({nft: NFToken({implem: nft, id: 1}), args: offerArgs1});

        return d;
    }
}
