// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./InternalBorrowTestCommons.sol";
import "../SetUp.sol";
import "../../DataStructure/Objects.sol";


contract TestBorrowCheckers is InternalBorrowTestCommons, SetUp {
    using MerkleProof for bytes32[];



    function testAddressRecovery() public {
        Offer memory offer;
        OfferArgs memory args;

        offer.expirationDate = block.timestamp + 2 weeks;

        Root memory root = Root({root: keccak256(abi.encode(offer))});
        args.root = root;
        args.signature = getSignatureInternal(root);

        assertEq(signer, checkOfferArgs(args));
    }

    function testMerkleTree() public {
        OfferArgs memory args;
        Offer memory offer1;
        Offer memory offer2;
        offer2.loanToValue = 1;
        offer1.expirationDate = 1 weeks;
        offer2.expirationDate = 1 weeks;

        bytes32 hashOne = keccak256(abi.encode(offer1));
        bytes32 hashTwo = keccak256(abi.encode(offer2));
        // hashOne < hashTwo = true
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = hashTwo;
        Root memory root = Root({root: keccak256(bytes.concat(hashOne, hashTwo))});
        args.root = root;
        args.proof = proof;
        args.signature = getSignatureInternal(root);
        // offer1 is implicitely included in args
        checkOfferArgs(args);
        offer2.loanToValue = 2;
        args.offer = offer2;
        vm.expectRevert(abi.encodeWithSelector(OfferNotFound.selector, offer2, root));
        this.checkOfferArgsExternal(args);
    }

    function testExpirationDate() public {

        Offer memory _offer =  Offer({
        assetToLend: money,
        loanToValue: 10 ether,
        duration: 1 weeks,
        expirationDate: block.timestamp + 2 weeks,
        collatSpecType: CollatSpecType.Floor,
        tranche: 0,
        collatSpecs: abi.encode(FloorSpec({implem: nft}))
        });



        Root memory root = Root({root: keccak256(abi.encode(_offer))});
        bytes32[] memory emptyArray;
        OfferArgs memory _offerArgs =  OfferArgs({
            proof: emptyArray,
            root: root,
            signature: getSignatureInternal(root),
            amount: 1 ether,
            offer: _offer
        });
        testExpirationDateRevert(_offerArgs);
        testExpirationDateAccept(_offerArgs);

    }

    function testAmount() public {
        OfferArgs memory args;
        Offer memory offer;
        offer.expirationDate =
        args.offer.expirationDate = block.timestamp + 2 weeks;
        Root memory root = Root({root: keccak256(abi.encode(offer))});
        args.amount = 1 ether;
        args.root = root;
        args.signature = getSignatureInternal(root);
        vm.expectRevert(abi.encodeWithSelector(RequestedAmountTooHigh.selector, 1 ether, uint256(0)));
        this.checkOfferArgsExternal(args);
    }

    // todo : check collat specs tests

    // helpers //

    function checkOfferArgsExternal(OfferArgs memory args) public view returns (address) {
        return checkOfferArgs(args);
    }


    function testExpirationDateAccept(OfferArgs memory args)internal{
        vm.warp(args.offer.expirationDate - 1 days);
        checkOfferArgs(args);
    }
    function testExpirationDateRevert(OfferArgs memory args)internal{
        vm.warp(args.offer.expirationDate + 1 days);
        checkOfferArgs(args);
        vm.expectRevert(abi.encodeWithSelector(OfferHasExpired.selector, args, block.timestamp + 1 weeks));
    }
}
