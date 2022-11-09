// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "diamond/Diamond.sol";
import "../BorrowLogic/BorrowCheckers.sol";
import "../interface/ISupplyPositionFacet.sol";
import "../interface/IKairos.sol";
import "../ContractsCreator.sol";
import "../utils/FuncSelectors.h.sol";
import "../interface/IProtocolFacet.sol";
import "../SupplyPositionFacet.sol";
import "../interface/IRepayFacet.sol";
import "./DCHelperFacet.sol";
import "../interface/IAuctionFacet.sol";
import "./Loggers.sol";

error AssertionFailedLoanDontMatch();
error AssertionFailedRayDontMatch(Ray expected, Ray actual);

contract TestConstructor is Test, ContractsCreator {
    using RayMath for Ray;

    uint256[] internal oneInArray;
    uint256 internal constant KEY = 0xA11CE;
    uint256 internal constant KEY2 = 0xB0B;
    address internal immutable signer;
    address internal immutable signer2;
    bytes4 internal immutable erc721SafeTransferFromSelector;
    bytes4 internal immutable erc721SafeTransferFromDataSelector;
    IKairos internal kairos;
    Money internal money;
    Money internal money2;
    NFT internal nft;
    NFT internal nft2;
    DCHelperFacet internal helper;

    constructor() {
        createContracts();
        helper = new DCHelperFacet();
        oneInArray = new uint256[](1);
        oneInArray[0] = 1;
        signer = vm.addr(KEY);
        signer2 = vm.addr(KEY2);
        vm.label(signer, "signer");
        vm.label(signer2, "signer2");
        erc721SafeTransferFromSelector = getSelector("safeTransferFrom(address,address,uint256)");
        erc721SafeTransferFromDataSelector = getSelector("safeTransferFrom(address,address,uint256,bytes)");
        protocolStorage().tranche[0] = ONE.div(10).mul(4).div(365 days); // 40% APR
    }
}
