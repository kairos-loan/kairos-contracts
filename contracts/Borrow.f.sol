// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "./DataStructure.sol";
import "./utils/WadRayMath.sol";
import "./Signature.sol";

/// @notice public facing methods for borrowers
contract BorrowFacet is IERC721Receiver, Signature {
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

    event Borrow(Loan[] loans);

    // todo : add reentrency check
    // todo : add multiple offer support
    // todo : not ask all possible liq
    // todo : process supplier coins
    // todo : support supplier signed approval
    // todo : check and implement protocol rules
    // todo : allow receive money then hook to get the NFT
    // todo : enforce minimal offer duration // useful ? if minimal interest // maybe max also
    /// @inheritdoc IERC721Receiver
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns(bytes4) {
        Protocol storage proto = protocolStorage();
        OfferArgs[] memory args = abi.decode(data, (OfferArgs[]));
        Provision[] memory provisions = new Provision[](args.length);
        Loan[] memory loans = new Loan[](1);
        Ray matched; // proportion of the NFT matched by previous offers
        uint256 lent;
        address signer;
        uint256 minOfferDuration = type(uint256).max;
        IERC20 assetLent = args[0].offer.assetToLend;

        for(uint8 i; i < args.length; i++) {
            if (i > 0 && args[i].offer.assetToLend != assetLent) {
                // all offers used for a collateral must refer to the same erc20
                revert InconsistentAssetRequests(assetLent, args[i].offer.assetToLend);
            }
            if (args[i].offer.collatSpecType == CollatSpecType.Floor) {
                FloorSpec memory spec = abi.decode(args[i].offer.collatSpecs, (FloorSpec));
                if (IERC721(msg.sender) != spec.collateral) { // check NFT address
                    revert NFTContractDoesntMatchOfferSpecs(IERC721(msg.sender), spec.collateral);
                }
            } else if (args[i].offer.collatSpecType == CollatSpecType.Single) {
                SingleSpec memory spec = abi.decode(args[i].offer.collatSpecs, (SingleSpec));
                if (IERC721(msg.sender) != spec.collateral) { // check NFT address
                    revert NFTContractDoesntMatchOfferSpecs(IERC721(msg.sender), spec.collateral);
                }
                if (tokenId != spec.tokenId) {
                    revert TokenIdDoesntMatchOfferSpecs(tokenId, spec.tokenId); 
                }
            }
            else {
                revert UnknownCollatSpecType(args[i].offer.collatSpecType); 
            }
            if (!args[i].proof.verify(args[i].root.root, keccak256(abi.encode(args[i].offer)))) {
                revert OfferNotFound(args[i].offer, args[i].root);
            }
            signer = ECDSA.recover(rootDigest(args[i].root), args[i].signature);
            if (proto.supplierNonce[signer] != args[i].offer.nonce) {
                revert OfferHasBeenDeleted(args[i].offer, proto.supplierNonce[signer]);
            }
            if (args[i].amount > args[i].offer.loanToValue) {
                revert RequestedAmountTooHigh(args[i].amount, args[i].offer.loanToValue);
            }
            matched = matched.add(args[i].amount.divToRay(args[i].offer.loanToValue));
            if (matched.gt(ONE)) {
                revert RequestedAmountTooHigh(
                    args[i].amount, 
                    args[i].offer.loanToValue - args[i].offer.loanToValue.mul(matched));
            }
            if (args[i].offer.duration < minOfferDuration) {minOfferDuration = args[i].offer.duration;}
            assetLent.transferFrom(signer, msg.sender, args[i].amount);
            provisions[i] = Provision({
                supplier: signer,
                amount: args[i].amount
            });
            lent += args[i].amount;
        }
        proto.nbOfLoans++;
        loans[0] = Loan({
            assetLent: assetLent,
            lent: lent,
            endDate: block.timestamp + minOfferDuration,
            tranche: 0, // will change in future implem
            borrower: from,
            collateral: IERC721(msg.sender),
            tokenId: tokenId,
            provisions : provisions
        });
        proto.loan[proto.nbOfLoans] = loans[0];
        
        emit Borrow(loans);
        
        return this.onERC721Received.selector;
    }

    function rootDigest(Root memory _root) public view returns(bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(
            ROOT_TYPEHASH,
            _root.root
        )));
    }
}