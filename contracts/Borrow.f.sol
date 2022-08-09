// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "./DataStructure.sol";

/// @notice Borrow Facet
contract Borrow {
    struct BorrowArgs {
        Offer offer;
        bytes signature;
    }

    // todo : add reentrency check
    // todo : add multiple offer support
    // todo : not ask all possible liq
    // todo : process supplier coins
    // todo : support supplier signed approval
    // todo : check and implement protocol rules
    // todo : allow receive money then hook to get the NFT
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns(bytes4) {
        BorrowArgs memory args = abi.decode(data, (BorrowArgs));
        if (args.offer.collatSpecType == CollatSpecType.Floor) {
            FloorSpec memory spec = abi.decode(args.offer.collatSpecs, (FloorSpec));
            if (IERC721(msg.sender) != spec.collateral) { // check NFT address
                revert NFTContractDoesntMatchOfferSpecs(IERC721(msg.sender), spec.collateral);
            }
        } else {
            revert UnknownCollatSpecType(args.offer.collatSpecType); 
        }

        // todo : retrieve supplier addr from sig and send mouney

        // offer.assetToLend.transferFrom(offer.)
        
        return this.onERC721Received.selector;
    }
}