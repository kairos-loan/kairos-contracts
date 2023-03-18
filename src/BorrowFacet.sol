// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {IBorrowFacet} from "./interface/IBorrowFacet.sol";

import {BorrowHandlers} from "./BorrowLogic/BorrowHandlers.sol";
import {BorrowArg, NFToken, Offer, OfferArg} from "./DataStructure/Objects.sol";
import {Signature} from "./Signature.sol";

/// @notice public facing methods for borrowing
/// @dev contract handles all borrowing logic through inheritance
contract BorrowFacet is IBorrowFacet, BorrowHandlers {
    /// @notice borrow using sent NFT as collateral without needing approval through transfer callback
    /// @param operator account that initialized the transfer action according to the NFT implementation contract
    /// @param tokenId token identifier of the NFT sent according to the NFT implementation contract
    /// @param data abi encoded arguments for the loan
    /// @return selector `this.onERC721Received.selector` ERC721-compliant response, signaling compatibility
    /// @dev param data must be of format OfferArg[]
    function onERC721Received(
        address operator,
        address, // from
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        OfferArg[] memory args = abi.decode(data, (OfferArg[]));

        // `operator` will be considered the borrower, enabling integration contracts to fully manage loans,
        // similarly how an approved contract can take a loan on behalf of the nft owner with the `borrow` method
        useCollateral(args, operator, NFToken({implem: IERC721(msg.sender), id: tokenId}));

        return this.onERC721Received.selector;
    }

    /// @notice take loans, take ownership of NFTs specified as collateral, sends borrowed money to caller
    /// @param args list of arguments specifying at which terms each collateral should be used
    function borrow(BorrowArg[] calldata args) external {
        for (uint256 i = 0; i < args.length; i++) {
            args[i].nft.implem.transferFrom(msg.sender, address(this), args[i].nft.id);
            useCollateral(args[i].args, msg.sender, args[i].nft);
        }
    }
}
