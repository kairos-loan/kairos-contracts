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
import "../interface/IDCHelperFacet.sol";
import "../AuctionFacet.sol";
import "../interface/IAuctionFacet.sol";

error AssertionFailedLoanDontMatch();
error AssertionFailedRayDontMatch(Ray expected, Ray actual);

contract TestCommons is Test {
    using RayMath for Ray;

    uint256 internal constant KEY = 0xA11CE;
    uint256 internal constant KEY2 = 0xB0B;
    address internal immutable signer;
    address internal immutable signer2;
    Diamond internal nftaclp;
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
    Money internal money;
    Money internal money2;
    NFT internal nft;
    NFT internal nft2;
    bytes4 immutable internal erc721SafeTransferFromSelector;
    bytes4 immutable internal erc721SafeTransferFromDataSelector;

    constructor() {
        signer = vm.addr(KEY);
        signer2 = vm.addr(KEY2);
        vm.label(signer, "signer");
        vm.label(signer2, "signer2");
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
        protocolStorage().tranche[0] = ONE.div(10).mul(4).div(365 days); // 40% APR
        erc721SafeTransferFromSelector = getSelector("safeTransferFrom(address,address,uint256)");
        erc721SafeTransferFromDataSelector = getSelector("safeTransferFrom(address,address,uint256,bytes)");
    }

    function assertEq(Loan memory actual, Loan memory expected) internal view {
        if(keccak256(abi.encode(actual)) != keccak256(abi.encode(expected))) {
            logLoan(expected, "expected");
            logLoan(actual, "actual  ");
            revert AssertionFailedLoanDontMatch();
        }
    }

    function assertEq(Ray actual, Ray expected) internal pure {
        if(Ray.unwrap(actual) != Ray.unwrap(expected)){
            revert AssertionFailedRayDontMatch(expected, actual);
        }
    }

    function getRootOfTwoHashes(bytes32 hashOne, bytes32 hashTwo) internal pure returns(Root memory ret){
        ret.root = hashOne < hashTwo 
            ? keccak256(abi.encode(hashOne, hashTwo)) 
            : keccak256(abi.encode(hashTwo, hashOne));
    }
}

/* solhint-disable func-visibility */

function logLoan(Loan memory loan, string memory name) view {
    console.log("~~~~~~~ start loan ", name, " ~~~~~~~");
    console.log("assetLent           ", address(loan.assetLent));
    console.log("lent                ", loan.lent);
    console.log("startDate           ", loan.startDate);
    console.log("endDate             ", loan.endDate);
    console.log("interestPerSecond   ", Ray.unwrap(loan.interestPerSecond));
    console.log("borrower            ", loan.borrower);
    console.log("collateral          ", address(loan.collateral));
    console.log("tokenId             ", loan.tokenId);
    console.log("repaid              ", loan.repaid);
    for(uint256 i; i < loan.supplyPositionIds.length; i++) {
        console.log("supplyPositionIds %s: %s", i, loan.supplyPositionIds[i]);
    }
    console.log("~~~~~~~ end loan ", name, "  ~~~~~~~");
}

function logOffer(Offer memory offer, string memory name) view {
    console.log("~~~~~~~ start offer ", name, " ~~~~~~~");
    console.log("assetToLend    ", address(offer.assetToLend));
    console.log("loanToValue    ", offer.loanToValue);
    console.log("duration       ", offer.duration);
    console.log("duration       ", offer.duration);
    console.log("collatSpecType ", uint8(offer.collatSpecType));
    console.log("tranche        ", offer.tranche);
    if (offer.collatSpecType == CollatSpecType.Floor) {
        FloorSpec memory spec = abi.decode(offer.collatSpecs, (FloorSpec));
        console.log("spec implem    ", address(spec.implem));
    } else {
        NFToken memory spec = abi.decode(offer.collatSpecs, (NFToken));
        console.log("spec implem    ", address(spec.implem));
        console.log("spec id        ", spec.id);
    }
    console.log("~~~~~~~ end offer ", name, "  ~~~~~~~");
}