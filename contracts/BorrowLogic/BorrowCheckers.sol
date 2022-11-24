// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../DataStructure/Global.sol";
import "../Signature.sol";

/// @notice handles checks to verify validity of a loan request
abstract contract BorrowCheckers is Signature {
    /// @notice computes EIP-712 compliant digest of a loan offer
    /// @param _offer the loan offer signed/to sign by a supplier
    /// @return digest the digest
    function offerDigest(Offer memory _offer) public view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(OFFER_TYPEHASH, _offer)));
    }

    /// @notice checks arguments validity for usage of one Offer
    /// @param args arguments for the Offer
    /// @return signer computed signer of `args.signature` according to `args.offer`
    function checkOfferArgs(OfferArgs memory args) internal view returns (address) {
        address signer = ECDSA.recover(offerDigest(args.offer), args.signature);

        if (block.timestamp > args.offer.expirationDate) {
            revert OfferHasExpired(args.offer, args.offer.expirationDate);
        }
        if (args.amount > args.offer.loanToValue) {
            revert RequestedAmountTooHigh(args.amount, args.offer.loanToValue);
        }

        return signer;
    }

    /// @notice checks collateral validity regarding the offer
    /// @param implem implementation address of the NFT collection provided
    /// @param tokenId token identifier of the provided NFT collateral
    /// @param offer loan offer which validity should be checked for the provided collateral
    function checkCollateral(IERC721 implem, uint256 tokenId, Offer memory offer) internal pure {
        if (implem != offer.collateral.implem || tokenId != offer.collateral.id) {
            revert BadCollateral(offer, tokenId, implem);
        }
    }
}
