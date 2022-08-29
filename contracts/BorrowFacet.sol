// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "./funcs/BorrowLogic.sol";

/// @notice public facing methods for borrowers
contract BorrowFacet is IERC721Receiver, BorrowLogic {
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

    function useCollateral(
        OfferArgs[] memory args, 
        address from, 
        NFToken memory nft
    ) internal returns(Loan memory loan) {
        Provision[] memory provisions = new Provision[](args.length);
        CollateralState memory collatState = CollateralState({
            matched: Ray.wrap(0),
            assetLent: args[0].offer.assetToLend,
            minOfferDuration: type(uint256).max,
            from: from,
            nft: nft
        });
        uint256 lent;

        for(uint8 i; i < args.length; i++) {
            (provisions[i], collatState) = useOffer(args[i], collatState);
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
            provisions : abi.encode(provisions)
        });
    }
}