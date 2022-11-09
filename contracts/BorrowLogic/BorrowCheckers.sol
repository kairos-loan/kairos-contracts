// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "../DataStructure/Global.sol";
import "../Signature.sol";

/// @notice handles checks to verify validity of a loan request
abstract contract BorrowCheckers is Signature {
    using MerkleProof for bytes32[];

    /// @notice computes EIP-712 compliant digest of a merkle root meant to be used by kairos
    /// @dev the corresponding merkle tree should have keccak256-hashed abi-encoded Offer(s) as leafs
    /// @param _root the root hash of the merkle tree
    /// @return digest the digest
    function rootDigest(Root memory _root) public view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(ROOT_TYPEHASH, _root.root)));
    }

    /// @notice checks arguments validity for usage of one Offer
    /// @param args arguments for the Offer
    /// @return signer computed signer of `args.signature` according to `args.offer`
    function checkOfferArgs(OfferArgs memory args) internal view returns (address) {
        Protocol storage proto = protocolStorage();
        address signer = ECDSA.recover(rootDigest(args.root), args.signature);

        if (!args.proof.verify(args.root.root, keccak256(abi.encode(args.offer)))) {
            revert OfferNotFound(args.offer, args.root);
        }
        /*
        if (proto.supplierNonce[msg.sender] != args.offer.nonce) {
            revert OfferHasBeenDeleted(args.offer, proto.supplierNonce[signer]);
        }
        */
        if (args.amount > args.offer.loanToValue) {
            revert RequestedAmountTooHigh(args.amount, args.offer.loanToValue);
        }

        return signer;
    }

    /// @notice checks collateral specifications validity regarding provided collateral
    /// @param collateral implementation address of the NFT collection provided
    /// @param tokenId token identifier of the provided NFT collateral
    /// @param offer loan offer which validity should be checked for the provided collateral
    function checkCollatSpecs(IERC721 collateral, uint256 tokenId, Offer memory offer) internal pure {
        CollatSpecType collatSpecType = offer.collatSpecType;

        if (collatSpecType == CollatSpecType.Floor) {
            FloorSpec memory spec = abi.decode(offer.collatSpecs, (FloorSpec));
            if (collateral != spec.implem) {
                // check NFT address
                revert NFTContractDoesntMatchOfferSpecs(collateral, spec.implem);
            }
        } else if (collatSpecType == CollatSpecType.Single) {
            NFToken memory spec = abi.decode(offer.collatSpecs, (NFToken));
            if (collateral != spec.implem) {
                // check NFT address
                revert NFTContractDoesntMatchOfferSpecs(collateral, spec.implem);
            }
            if (tokenId != spec.id) {
                revert TokenIdDoesntMatchOfferSpecs(tokenId, spec.id);
            }
        } else {
            revert UnknownCollatSpecType(offer.collatSpecType);
        }
    }
}
