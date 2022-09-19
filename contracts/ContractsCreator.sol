// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "diamond/facets/OwnershipFacet.sol";
import "diamond/facets/DiamondCutFacet.sol";
import "diamond/interfaces/IDiamondCut.sol";
import "diamond/facets/DiamondLoupeFacet.sol";
import "./Initializer.sol";
import "./utils/NFT.sol";
import "./utils/Money.sol";
import "./BorrowFacet.sol";
import "./ClaimFacet.sol";
import "./ProtocolFacet.sol";
import "./AuctionFacet.sol";
import "./RepayFacet.sol";
import "./utils/FuncSelectors.h.sol";

contract ContractsCreator {
    Initializer internal initializer;
    DiamondCutFacet internal cut;
    OwnershipFacet internal ownership;
    DiamondLoupeFacet internal loupe;
    BorrowFacet internal borrow;
    SupplyPositionFacet internal supplyPosition;
    ProtocolFacet internal protocol;
    RepayFacet internal repay;
    AuctionFacet internal auction;
    ClaimFacet internal claim;

    function createContracts() internal {
        cut = new DiamondCutFacet();
        loupe = new DiamondLoupeFacet();
        ownership = new OwnershipFacet();
        repay = new RepayFacet();
        borrow = new BorrowFacet();
        supplyPosition = new SupplyPositionFacet();
        protocol = new ProtocolFacet();
        initializer = new Initializer();
        auction = new AuctionFacet();
        claim = new ClaimFacet();
    }

    /* solhint-disable-next-line function-max-lines */
    function getFacetCuts() internal view returns(IDiamondCut.FacetCut[] memory) {
        IDiamondCut.FacetCut[] memory facetCuts = new IDiamondCut.FacetCut[](8);

        facetCuts[0] = IDiamondCut.FacetCut({
            facetAddress: address(loupe),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: loupeFS()
        });

        facetCuts[1] = IDiamondCut.FacetCut({
            facetAddress: address(ownership),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: ownershipFS()
        });

        facetCuts[2] = IDiamondCut.FacetCut({
            facetAddress: address(borrow),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: borrowFS()
        });

        facetCuts[3] = IDiamondCut.FacetCut({
            facetAddress: address(supplyPosition),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: supplyPositionFS()
        });

        facetCuts[4] = IDiamondCut.FacetCut({
            facetAddress: address(protocol),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: protoFS()
        });

        facetCuts[5] = IDiamondCut.FacetCut({
            facetAddress: address(repay),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: repayFS()
        });

        facetCuts[6] = IDiamondCut.FacetCut({
            facetAddress: address(auction),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: auctionFS()
        });

        facetCuts[7] = IDiamondCut.FacetCut({
            facetAddress: address(claim),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: claimFS()
        });

        return facetCuts;
    }
}
