// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../BorrowLogic/BorrowCheckers.sol";
import "../interface/ISupplyPositionFacet.sol";
import "diamond/Diamond.sol";
import "diamond/facets/OwnershipFacet.sol";
import "diamond/facets/DiamondCutFacet.sol";
import "diamond/interfaces/IDiamondCut.sol";
import "diamond/facets/DiamondLoupeFacet.sol";
import "../Initializer.sol";
import "../utils/FuncSelectors.h.sol";
import "../utils/NFT.sol";
import "../utils/Money.sol";
import "../BorrowFacet.sol";
import "../ProtocolFacet.sol";
import "../interface/IProtocolFacet.sol";
import "../SupplyPositionFacet.sol";
import "../RepayFacet.sol";
import "../interface/IRepayFacet.sol";
import "./DCHelperFacet.sol";
import "../AuctionFacet.sol";
import "../interface/IAuctionFacet.sol";
import "../ClaimFacet.sol";
import "./Loggers.sol";

error AssertionFailedLoanDontMatch();
error AssertionFailedRayDontMatch(Ray expected, Ray actual);

contract ExtendConstructor is Test {
    uint256[] internal oneInArray;
    uint256 internal constant KEY = 0xA11CE;
    uint256 internal constant KEY2 = 0xB0B;
    address internal immutable signer;
    address internal immutable signer2;
    bytes4 immutable internal erc721SafeTransferFromSelector;
    bytes4 immutable internal erc721SafeTransferFromDataSelector;
    Diamond internal nftaclp;
    Money internal money;
    Money internal money2;
    NFT internal nft;
    NFT internal nft2;

    constructor() {
        oneInArray = new uint256[](1);
        oneInArray[0] = 1;
        signer = vm.addr(KEY);
        signer2 = vm.addr(KEY2);
        vm.label(signer, "signer");
        vm.label(signer2, "signer2");
        erc721SafeTransferFromSelector = getSelector("safeTransferFrom(address,address,uint256)");
        erc721SafeTransferFromDataSelector = getSelector("safeTransferFrom(address,address,uint256,bytes)");
    }
}

contract Constructor is ExtendConstructor {
    using RayMath for Ray;

    Initializer internal initializer;
    DiamondCutFacet internal cut;
    OwnershipFacet internal ownership;
    DiamondLoupeFacet internal loupe;
    BorrowFacet internal borrow;
    SupplyPositionFacet internal supplyPosition;
    ProtocolFacet internal protocol;
    RepayFacet internal repay;
    DCHelperFacet internal helper;
    AuctionFacet internal auction;
    ClaimFacet internal claim;

    constructor() {
        cut = new DiamondCutFacet();
        loupe = new DiamondLoupeFacet();
        ownership = new OwnershipFacet();
        repay = new RepayFacet();
        borrow = new BorrowFacet();
        supplyPosition = new SupplyPositionFacet();
        protocol = new ProtocolFacet();
        helper = new DCHelperFacet();
        initializer = new Initializer();
        auction = new AuctionFacet();
        claim = new ClaimFacet();
        protocolStorage().tranche[0] = ONE.div(10).mul(4).div(365 days); // 40% APR
    }
}
