// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../Borrow.t.sol";

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

contract ComplexBorrowPreExecFuncs is TestBorrow {
    using RayMath for Ray;
    using RayMath for uint256;

    function prepareSigners() internal {
        vm.prank(signer2);
        kairos.updateOffers();

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
        bytes32 hashSign1Off1 = keccak256(abi.encode(d.signer1Offer1));
        bytes32 hashSign1Off2 = keccak256(abi.encode(d.signer1Offer2));
        bytes32 hashSign2Off = keccak256(abi.encode(d.signer2Offer));
        Root memory rootSign1 = getRootOfTwoHashes(hashSign1Off1, hashSign1Off2);
        Root memory rootSign2 = Root({root: hashSign2Off});
        bytes32[] memory proofSign1Off1 = new bytes32[](1);
        proofSign1Off1[0] = hashSign1Off2;
        bytes32[] memory proofSign1Off2 = new bytes32[](1);
        proofSign1Off2[0] = hashSign1Off1;
        bytes32[] memory proofSign2Off;
        d.oargs1 = OfferArgs({
            proof: proofSign1Off1,
            root: rootSign1,
            signature: getSignature(rootSign1),
            amount: 1 ether / 2, // 25%
            offer: d.signer1Offer1
        });
        d.oargs2 = OfferArgs({
            proof: proofSign2Off,
            root: rootSign2,
            signature: getSignature2(rootSign2),
            amount: 3 ether / 4, // 75%
            offer: d.signer2Offer
        });
        d.oargs3 = OfferArgs({
            proof: proofSign1Off2,
            root: rootSign1,
            signature: getSignature(rootSign1),
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
            expirationDate: 0,
            collatSpecType: CollatSpecType.Single,
            tranche: 0,
            collatSpecs: abi.encode(NFToken({
                implem: nft,
                id: 1}))});
        d.signer1Offer2 = Offer({
            assetToLend: money2,
            loanToValue: 2 ether,
            duration: 4 weeks,
            expirationDate: 0,
            collatSpecType: CollatSpecType.Single,
            tranche: 0,
            collatSpecs: abi.encode(NFToken({
                implem: nft2,
                id: 1}))});

        d.signer2Offer = Offer({
            assetToLend: money,
            loanToValue: 1 ether,
            duration: 1 weeks,
            expirationDate: 1,
            collatSpecType: CollatSpecType.Floor,
            tranche: 0,
            collatSpecs: abi.encode(FloorSpec({
                implem: nft}))});

        return d;
    }

    function initBorrowArgs(ComplexBorrowData memory d) internal view returns (ComplexBorrowData memory) {
        OfferArgs[] memory offerArgs1 = new OfferArgs[](2);
        offerArgs1[0] = d.oargs1;
        offerArgs1[1] = d.oargs2;
        OfferArgs[] memory offerArgs2 = new OfferArgs[](1);
        offerArgs2[0] = d.oargs3;

        d.bargs1 = BorrowArgs({
            nft: NFToken({
                implem: nft,
                id: 1
            }),
            args: offerArgs1
        });
        
        d.bargs2 = BorrowArgs({
            nft: NFToken({
                implem: nft2,
                id: 1
            }),
            args: offerArgs2
        });

        return d;
    }
}