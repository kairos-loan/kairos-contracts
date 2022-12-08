// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "./BorrowLogic/BorrowHandlers.sol";

/// @notice public facing methods for borrowing
/// @dev contract handles all borrowing logic through inheritance
contract BorrowFacet is IERC721Receiver, BorrowHandlers {
  // todo #19 add reentrency check
  // todo #20 process supplier coins
  // todo #21 support supplier signed approval
  // todo #22 support contract signatures (erc1271)
  // todo #23 check and implement protocol rules
  // todo #24 allow receive money then hook to get the NFT
  // todo #25 enforce minimal offer duration // useful ? if minimal interest // maybe max also
  /// @notice borrow using sent NFT as collateral without needing approval through transfer callback
  /// @param from owner of the NFT sent according to the NFT implementation contract
  /// @param tokenId token identifier of the NFT sent according to the NFT implementation contract
  /// @param data abi encoded arguments for the loan
  /// @return selector `this.onERC721Received.selector` ERC721-compliant response, signaling compatibility
  /// @dev param data must be of format OfferArgs[]
  /// @inheritdoc IERC721Receiver
  function onERC721Received(
    address,
    address from,
    uint256 tokenId,
    bytes calldata data
  ) external returns (bytes4) {
    OfferArgs[] memory args = abi.decode(data, (OfferArgs[]));
    Loan[] memory loans = new Loan[](1);

    loans[0] = useCollateral(args, from, NFToken({implem: IERC721(msg.sender), id: tokenId}));

    return this.onERC721Received.selector;
  }

  // todo #26 should return loan ids ?
  /// @notice take loans, take ownership of NFTs specified as collateral, sends borrowed money to caller
  /// @param args list of arguments specifying at which terms each collateral should be used
  function borrow(BorrowArgs[] calldata args) external {
    Loan[] memory loans = new Loan[](args.length);

    for (uint8 i; i < args.length; i++) {
      args[i].nft.implem.transferFrom(msg.sender, address(this), args[i].nft.id);
      loans[i] = useCollateral(args[i].args, msg.sender, args[i].nft);
    }
  }
}
