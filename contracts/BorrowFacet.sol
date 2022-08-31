// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "./BorrowLogic/BorrowHandlers.sol";

// todo : docs

/// @notice public facing methods for borrowers
contract BorrowFacet is IERC721Receiver, BorrowHandlers {
    struct BorrowArgs {
        NFToken nft;
        OfferArgs[] args;
    }

    event Borrow(Loan[] loans);

    // todo : add reentrency check
    // todo : process supplier coins
    // todo : support supplier signed approval
    // todo : check and implement protocol rules
    // todo : allow receive money then hook to get the NFT
    // todo : enforce minimal offer duration // useful ? if minimal interest // maybe max also
    /// @inheritdoc IERC721Receiver
    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns(bytes4) {
        Protocol storage proto = protocolStorage();
        OfferArgs[] memory args = abi.decode(data, (OfferArgs[]));
        Loan[] memory loans = new Loan[](1);

        proto.nbOfLoans++;

        loans[0] = useCollateral(args, from, NFToken({
            implem: IERC721(msg.sender),
            id: tokenId
        }));

        proto.loan[proto.nbOfLoans] = loans[0];
        
        emit Borrow(loans);
        
        return this.onERC721Received.selector;
    }

    function borrow(BorrowArgs[] calldata args) external {
        Protocol storage proto = protocolStorage();
        Loan[] memory loans = new Loan[](args.length);

        for(uint8 i; i < args.length; i++){
            args[i].nft.implem.transferFrom(msg.sender, address(this), args[i].nft.id);
            proto.nbOfLoans++;
            loans[i] = useCollateral(args[i].args, msg.sender, args[i].nft);
            proto.loan[proto.nbOfLoans] = loans[i];
        }

        emit Borrow(loans);
    }
}