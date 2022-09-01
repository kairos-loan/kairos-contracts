// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "./InternalBorrowTestCommons.sol";

contract TestBorrowCheckers is InternalBorrowTestCommons {
    using MerkleProof for bytes32[];

    // function setUp() public {
    //     Protocol storage proto = protocolStorage();
    //     proto.supplierNonce[signer] = 3;
    // }

    function testAddressRecovery() public {
        Offer memory offer;
        OfferArgs memory args;

        Root memory root = Root({root: keccak256(abi.encode(offer))});
        args.root = root;
        args.signature = getSignature(root);
        assertEq(signer, checkOfferArgs(args));
    }

    function testMerkleTree() public {
        OfferArgs memory args;
        Offer memory offer1;
        Offer memory offer2;
        offer2.loanToValue = 1;
        bytes32 hashOne = keccak256(abi.encode(offer1));
        bytes32 hashTwo = keccak256(abi.encode(offer2));
        // hashOne < hashTwo = true
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = hashTwo;
        Root memory root = Root({root: keccak256(bytes.concat(hashOne, hashTwo))});
        args.root = root;
        args.proof = proof;
        args.signature = getSignature(root);
        // offer1 is implicitely included in args
        checkOfferArgs(args);
        offer2.loanToValue = 2;
        args.offer = offer2;
        vm.expectRevert(abi.encodeWithSelector(OfferNotFound.selector, offer2, root));
        this.checkOfferArgsExternal(args);
    }

    function testNonce() public {
        OfferArgs memory args;
        Offer memory offer;
        offer.nonce = 1;
        // stored supplier nonce is implicitely 0
        Root memory root = Root({root: keccak256(abi.encode(offer))});
        args.root = root;
        args.offer = offer;
        args.signature = getSignature(root);
        vm.expectRevert(abi.encodeWithSelector(OfferHasBeenDeleted.selector, offer, uint256(0)));
        this.checkOfferArgsExternal(args);
    }

    function testAmount() public {
        OfferArgs memory args;
        Offer memory offer;
        Root memory root = Root({root: keccak256(abi.encode(offer))});

        args.amount = 1 ether;
        args.root = root;
        args.signature = getSignature(root);
        vm.expectRevert(abi.encodeWithSelector(RequestedAmountTooHigh.selector, 1 ether, uint256(0)));
        this.checkOfferArgsExternal(args);
    }

    // helpers //

    function checkOfferArgsExternal(OfferArgs memory args) public view returns (address) {
        return checkOfferArgs(args);
    }
}