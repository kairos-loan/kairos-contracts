// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "./funcs/BorrowLogic.sol";

/// @notice public facing methods for borrowers
contract BorrowFacet is IERC721Receiver, BorrowLogic {

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
        Provision[] memory provisions = new Provision[](args.length);
        Loan[] memory loans = new Loan[](1);
        uint256 lent;
        Provision memory tempProvision;
        CollateralState memory collatState = CollateralState({
            implementation: IERC721(msg.sender),
            tokenId: tokenId,
            matched: Ray.wrap(0),
            assetLent: args[0].offer.assetToLend,
            minOfferDuration: type(uint256).max,
            from: from
        });

        for(uint8 i; i < args.length; i++) {
            (tempProvision, collatState) = useOffer(args[i], collatState);
            provisions[i] = tempProvision;
            lent += args[i].amount;
        }
        
        proto.nbOfLoans++;
        loans[0] = Loan({
            assetLent: collatState.assetLent,
            lent: lent,
            endDate: block.timestamp + collatState.minOfferDuration,
            tranche: 0, // will change in future implem
            borrower: from,
            collateral: IERC721(msg.sender),
            tokenId: tokenId,
            provisions : abi.encode(provisions)
        });
        proto.loan[proto.nbOfLoans] = loans[0];
        
        emit Borrow(loans);
        
        return this.onERC721Received.selector;
    }
}