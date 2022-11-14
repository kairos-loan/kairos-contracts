// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./InternalBorrowTestCommons.sol";
import "../../DataStructure/Objects.sol";
import "../SetUp.sol";


contract TestBorrowCheckers is InternalBorrowTestCommons, SetUp {
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
        args.signature = getSignatureInternal(root);
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
        expirationDate: 2 weeks,
        collatSpecType: CollatSpecType.Floor,
        tranche: 0,
        collatSpecs: abi.encode(FloorSpec({implem: nft}))
        });

        //Modify this value to test
        vm.warp(13 days + 23 hours + 59 minutes + 59 seconds);

        Root memory root = Root({root: keccak256(abi.encode(_offer))});
        bytes32[] memory emptyArray;

        checkOfferArgs(OfferArgs({
        proof: emptyArray,
        root: root,
        signature: getSignatureInternal(root),
        amount: 1 ether,
        offer: _offer
        }));



        //checkOfferArgs(offerArgs[0]);
        //vm.expectRevert(OfferHasBeenDeleted);


        //Root memory root = Root({root: keccak256(abi.encode(offer))});
        //args.root = root;
        //args.offer = offer;
        //args.signature = getSignatureInternal(root);
        //vm.expectRevert(abi.encodeWithSelector(OfferHasBeenDeleted.selector, offer, uint256(0)));
        //this.checkOfferArgsExternal(args);
    }

    function testAmount() public {
        OfferArgs memory args;
        Offer memory offer;
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
}
