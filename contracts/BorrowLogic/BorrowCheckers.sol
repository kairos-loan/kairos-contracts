// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "../DataStructure/Global.sol";
import "../Signature.sol";

// todo : docs

abstract contract BorrowCheckers is Signature {
    using MerkleProof for bytes32[];

    function rootDigest(Root memory _root) public view returns(bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(
            ROOT_TYPEHASH,
            _root.root
        )));
    }

    function checkOfferArgs(OfferArgs memory args) internal view returns (address){
        Protocol storage proto = protocolStorage();
        address signer = ECDSA.recover(rootDigest(args.root), args.signature);

        if (!args.proof.verify(args.root.root, keccak256(abi.encode(args.offer)))) {
            revert OfferNotFound(args.offer, args.root);
        }
        if (proto.supplierNonce[signer] != args.offer.nonce) {
            revert OfferHasBeenDeleted(args.offer, proto.supplierNonce[signer]);
        }
        if (args.amount > args.offer.loanToValue) {
            revert RequestedAmountTooHigh(args.amount, args.offer.loanToValue);
        }

        return signer;
    }

    function checkCollatSpecs(IERC721 collateral, uint256 tokenId, Offer memory offer) internal pure {
        CollatSpecType collatSpecType = offer.collatSpecType;

        if (collatSpecType == CollatSpecType.Floor) {
            FloorSpec memory spec = abi.decode(offer.collatSpecs, (FloorSpec));
            if (collateral != spec.implem) { // check NFT address
                revert NFTContractDoesntMatchOfferSpecs(collateral, spec.implem);
            }
        } else if (collatSpecType == CollatSpecType.Single) {
            NFToken memory spec = abi.decode(offer.collatSpecs, (NFToken));
            if (collateral != spec.implem) { // check NFT address
                revert NFTContractDoesntMatchOfferSpecs(collateral, spec.implem);
            }
            if (tokenId != spec.id) {
                revert TokenIdDoesntMatchOfferSpecs(tokenId, spec.id); 
            }
        }
        else {
            revert UnknownCollatSpecType(offer.collatSpecType); 
        }
    }
}