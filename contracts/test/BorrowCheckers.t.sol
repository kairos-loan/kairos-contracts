// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "../BorrowLogic/BorrowCheckers.sol";
import "./TestCommons.sol";

contract BorrowCheckersTest is TestCommons, BorrowCheckers {
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
        checkOfferArgs(args);
        offer2.loanToValue = 2;
        args.offer = offer2;
        vm.expectRevert(abi.encodeWithSelector(OfferNotFound.selector, offer2, root));
        this.checkOfferArgsExternal(args);
    }

    // helpers //

    function checkOfferArgsExternal(OfferArgs memory args) public view returns (address) {
        return checkOfferArgs(args);
    }

    function getSignature(Root memory root) private returns(bytes memory signature){
        bytes32 digest = rootDigest(root);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(KEY, digest);
        signature = bytes.concat(r, s, bytes1(v));
    }
}