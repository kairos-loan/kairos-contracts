// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "../DataStructure.sol";
import "../Signature.sol";
import "../utils/WadRayMath.sol";
import "../SupplyPositionFacet.sol";

// todo : docs

abstract contract BorrowLogic is Signature {
    using MerkleProof for bytes32[];
    using WadRayMath for Ray;
    using WadRayMath for uint256;

    function rootDigest(Root memory _root) public view returns(bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(
            ROOT_TYPEHASH,
            _root.root
        )));
    }

    function useOffer(
        OfferArgs memory args,
        CollateralState memory collatState
    ) internal returns(
        uint256 supplyPositionId, 
        CollateralState memory
    ) {
        address signer = checkOfferArgs(args);
        Ray shareMatched;

        if (args.offer.assetToLend != collatState.assetLent) {
            // all offers used for a collateral must refer to the same erc20
            revert InconsistentAssetRequests(collatState.assetLent, args.offer.assetToLend);
        }

        checkCollatSpecs(collatState.nft.implem, collatState.nft.id, args.offer);
        shareMatched = args.amount.divToRay(args.offer.loanToValue);
        collatState.matched = collatState.matched.add(shareMatched);

        if (collatState.matched.gt(ONE)) {
            revert RequestedAmountTooHigh(
                args.amount, 
                args.offer.loanToValue - args.offer.loanToValue.mul(collatState.matched));
        }
        if (args.offer.duration < collatState.minOfferDuration) {collatState.minOfferDuration = args.offer.duration;}

        collatState.assetLent.transferFrom(signer, collatState.from, args.amount);

        return(SupplyPositionFacet(address(this)).safeMint(signer, Provision({
            amount: args.amount,
            share: shareMatched
        })), collatState);
    }

    function useCollateral(
        OfferArgs[] memory args, 
        address from, 
        NFToken memory nft
    ) internal returns(Loan memory loan) {
        uint256[] memory supplyPositionIds = new uint256[](args.length);
        CollateralState memory collatState = CollateralState({
            matched: Ray.wrap(0),
            assetLent: args[0].offer.assetToLend,
            minOfferDuration: type(uint256).max,
            from: from,
            nft: nft
        });
        uint256 lent;

        for(uint8 i; i < args.length; i++) {
            (supplyPositionIds[i], collatState) = useOffer(args[i], collatState);
            lent += args[i].amount;
        }

        loan = Loan({
            assetLent: collatState.assetLent,
            lent: lent,
            endDate: block.timestamp + collatState.minOfferDuration,
            tranche: 0, // will change in future implem
            borrower: from,
            collateral: IERC721(msg.sender),
            tokenId: nft.id,
            supplyPositionIds : supplyPositionIds
        });
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