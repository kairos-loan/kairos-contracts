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

        facetCuts[0] = IDiamond.FacetCut({
            facetAddress: address(loupe),
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: loupeFS()
        });

        facetCuts[1] = IDiamond.FacetCut({
            facetAddress: address(ownership),
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: ownershipFS()
        });

        facetCuts[2] = IDiamond.FacetCut({
            facetAddress: address(borrow),
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: borrowFS()
        });

        facetCuts[3] = IDiamond.FacetCut({
            facetAddress: address(supplyPosition),
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: supplyPositionFS()
        });

        facetCuts[4] = IDiamond.FacetCut({
            facetAddress: address(protocol),
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: protoFS()
        });

        facetCuts[5] = IDiamond.FacetCut({
            facetAddress: address(repay),
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: repayFS()
        });

        facetCuts[6] = IDiamond.FacetCut({
            facetAddress: address(auction),
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: auctionFS()
        });

        facetCuts[7] = IDiamond.FacetCut({
            facetAddress: address(claim),
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: claimFS()
        });

        return facetCuts;
    }
}
