// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {OwnershipFacet} from "diamond/contracts/facets/OwnershipFacet.sol";
import {DiamondCutFacet} from "diamond/contracts/facets/DiamondCutFacet.sol";
import {IDiamond} from "diamond/contracts/interfaces/IDiamond.sol";
import {IDiamondCut} from "diamond/contracts/interfaces/IDiamondCut.sol";
import {DiamondLoupeFacet} from "diamond/contracts/facets/DiamondLoupeFacet.sol";

import {AdminFacet} from "./AdminFacet.sol";
import {AuctionFacet} from "./AuctionFacet.sol";
import {BorrowFacet} from "./BorrowFacet.sol";
import {ClaimFacet} from "./ClaimFacet.sol";
import {Initializer} from "./Initializer.sol";
import {ProtocolFacet} from "./ProtocolFacet.sol";
import {RepayFacet} from "./RepayFacet.sol";
import {SupplyPositionFacet} from "./SupplyPositionFacet.sol";
/* solhint-disable-next-line max-line-length */
import {adminFS, auctionFS, claimFS, borrowFS, cutFS, loupeFS, protoFS, ownershipFS, repayFS, supplyPositionFS} from "./utils/FuncSelectors.h.sol";

/// @notice handles uinitialized deployment of all contracts of the protocol and exposes facet cuts
/// @dev for production, the 3 contracts imported from diamonds don't have to be redeployed as they are already
///      existing on most chain, modify deploy script accordingly
contract ContractsCreator {
    Initializer internal initializer;
    DiamondCutFacet internal cut;
    OwnershipFacet internal ownership;
    DiamondLoupeFacet internal loupe;
    AdminFacet internal admin;
    BorrowFacet internal borrow;
    SupplyPositionFacet internal supplyPosition;
    ProtocolFacet internal protocol;
    RepayFacet internal repay;
    AuctionFacet internal auction;
    ClaimFacet internal claim;

    /// @notice deploys all contracts uninitialized
    function createContracts() internal {
        admin = new AdminFacet();
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

    /// @notice get all facet cuts to add to add to a diamond to create kairos
    /// @return facetCuts the list of facet cuts
    /* solhint-disable-next-line function-max-lines */
    function getFacetCuts() internal view returns (IDiamondCut.FacetCut[] memory) {
        IDiamondCut.FacetCut[] memory facetCuts = new IDiamondCut.FacetCut[](10);

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
            facetAddress: address(cut),
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: cutFS()
        });

        facetCuts[3] = IDiamond.FacetCut({
            facetAddress: address(borrow),
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: borrowFS()
        });

        facetCuts[4] = IDiamond.FacetCut({
            facetAddress: address(supplyPosition),
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: supplyPositionFS()
        });

        facetCuts[5] = IDiamond.FacetCut({
            facetAddress: address(protocol),
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: protoFS()
        });

        facetCuts[6] = IDiamond.FacetCut({
            facetAddress: address(repay),
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: repayFS()
        });

        facetCuts[7] = IDiamond.FacetCut({
            facetAddress: address(auction),
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: auctionFS()
        });

        facetCuts[8] = IDiamond.FacetCut({
            facetAddress: address(claim),
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: claimFS()
        });

        facetCuts[9] = IDiamond.FacetCut({
            facetAddress: address(admin),
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: adminFS()
        });

        return facetCuts;
    }
}
