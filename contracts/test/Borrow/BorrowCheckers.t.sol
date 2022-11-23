// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./BorrowTestCommons.sol";
import "../SetUp.sol";

contract TestBorrowCheckers is BorrowTestCommons, SetUp {
    using MerkleProof for bytes32[];

    function testAddressRecovery() public {
        Offer memory offer;
        OfferArgs memory args;

        offer.expirationDate = block.timestamp + 2 weeks;
        args.offer = offer;

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
        offer1.expirationDate = block.timestamp + 2 weeks;
        args.offer = offer1;

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
        Offer memory offer1;
        Offer memory offer2;
        OfferArgs memory args1;
        OfferArgs memory args2;

        offer1.expirationDate = block.timestamp + 2 weeks;
        args1.offer = offer1;
        Root memory root1 = Root({root: keccak256(abi.encode(offer1))});
        args1.root = root1;
        args1.signature = getSignatureInternal(root1);
        vm.warp(args1.offer.expirationDate - 1);
        checkOfferArgs(args1);

        offer2.expirationDate = block.timestamp + 2 weeks;
        args2.offer = offer2;
        Root memory root2 = Root({root: keccak256(abi.encode(offer2))});
        args2.root = root2;
        args2.signature = getSignatureInternal(root2);
        vm.warp(args2.offer.expirationDate + 1);
        vm.expectRevert(
            abi.encodeWithSelector(OfferHasExpired.selector, args2.offer, args2.offer.expirationDate)
        );
        this.checkOfferArgsExternal(args2);
    }

    function testAmount() public {
        OfferArgs memory args;
        Offer memory offer;
        offer.loanToValue = 1 ether - 1;
        offer.expirationDate = block.timestamp + 2 weeks;
        args.offer = offer;
        Root memory root = Root({root: keccak256(abi.encode(offer))});
        args.amount = 1 ether;
        args.root = root;
        args.signature = getSignatureInternal(root);
        vm.expectRevert(abi.encodeWithSelector(RequestedAmountTooHigh.selector, 1 ether, 1 ether - 1));
        this.checkOfferArgsExternal(args);
    }
}
