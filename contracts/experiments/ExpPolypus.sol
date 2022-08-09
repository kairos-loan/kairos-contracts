// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../DataStructure.sol";

/// @notice Polypus public facing functions
/// @dev experiment only, Polypus will be organized around facets & use diamond storage
contract ExpPolypus is IERC721Receiver, ReentrancyGuard {
    Protocol internal protocol; 

    constructor(Ray rateOfTranche0Ray) {
        protocol.rateOfTranche[0] = rateOfTranche0Ray;
    }
    
    // todo : implement borrowing through here, useful to skip approval step
    // todo : prevent reentrency
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) 
        external returns(bytes4) {}

    // todo : ask not for all value
    // todo : ask for specific endDate
    // todo : process supplier coins
    function borrow(Offer calldata offer, IERC721 collateral, uint256 collatTokenId) internal nonReentrant {
        // todo : externalize transfer
        collateral.transferFrom(msg.sender, address(this), collatTokenId);
        if (offer.collatSpecType == CollatSpecType.Floor) {
            (FloorSpec memory spec) = abi.decode(offer.collatSpecs, (FloorSpec));
            if (collateral != spec.collateral) {
                revert CollateralDoesntMatchSpecs(collateral, collatTokenId);
            }
            // offer.assetToLend.transferFrom(offer.supplier, msg.sender, offer.loanToValue);
        } else {
            revert UnknownCollatSpecType(offer.collatSpecType); 
        }
    }

}