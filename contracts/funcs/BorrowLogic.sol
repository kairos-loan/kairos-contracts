// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "../DataStructure.sol";
import "../Signature.sol";
import "../utils/WadRayMath.sol";

abstract contract BorrowLogic is Signature {
    using MerkleProof for bytes32[];
    using WadRayMath for Ray;
    using WadRayMath for uint256;

    /// @notice Arguments for the borrow parameters of an offer
    /// @dev '-' means n^th
    ///     possible opti is to use OZ's multiProofVerify func, not used here
    ///     because it can mess with the ordering of the offer usage
    /// @member proof - of the offer inclusion in his tree
    /// @member root - of the supplier offer merkle tree
    /// @member signature - of the supplier offer merkle tree root
    /// @member amount - to borrow from this offer
    /// @member offer intended for usage in the loan
    struct OfferArgs {
        bytes32[] proof;
        Root root;
        bytes signature;
        uint256 amount;
        Offer offer;
    }

    struct CollateralState {
        IERC721 implementation;
        uint256 tokenId;
        Ray matched;
        IERC20 assetLent;
        uint256 minOfferDuration;
        address from;
    }

    function rootDigest(Root memory _root) public view returns(bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(
            ROOT_TYPEHASH,
            _root.root
        )));
    }

    function useOffer(
        OfferArgs memory args,
        CollateralState memory collatState) internal returns(
            Provision memory, 
            CollateralState memory) {
        address signer = checkOfferArgs(args);

        if (args.offer.assetToLend != collatState.assetLent) {
            // all offers used for a collateral must refer to the same erc20
            revert InconsistentAssetRequests(collatState.assetLent, args.offer.assetToLend);
        }

        checkCollatSpecs(collatState.implementation, collatState.tokenId, args.offer);
        collatState.matched = collatState.matched.add(args.amount.divToRay(args.offer.loanToValue));

        if (collatState.matched.gt(ONE)) {
            revert RequestedAmountTooHigh(
                args.amount, 
                args.offer.loanToValue - args.offer.loanToValue.mul(collatState.matched));
        }
        if (args.offer.duration < collatState.minOfferDuration) {collatState.minOfferDuration = args.offer.duration;}

        collatState.assetLent.transferFrom(signer, collatState.from, args.amount);

        return(
            Provision({
                supplier: signer,
                amount: args.amount
            }), collatState);
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
            if (collateral != spec.collateral) { // check NFT address
                revert NFTContractDoesntMatchOfferSpecs(collateral, spec.collateral);
            }
        } else if (collatSpecType == CollatSpecType.Single) {
            SingleSpec memory spec = abi.decode(offer.collatSpecs, (SingleSpec));
            if (collateral != spec.collateral) { // check NFT address
                revert NFTContractDoesntMatchOfferSpecs(collateral, spec.collateral);
            }
            if (tokenId != spec.tokenId) {
                revert TokenIdDoesntMatchOfferSpecs(tokenId, spec.tokenId); 
            }
        }
        else {
            revert UnknownCollatSpecType(offer.collatSpecType); 
        }
    }
}