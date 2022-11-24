// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";

import "./Loggers.sol";
import "./Money.sol";
import "./NFT.sol";
import {getSelector} from "contracts/utils/FuncSelectors.h.sol";

abstract contract TestCommons is Loggers {
    error AssertionFailedLoanDontMatch();
    error AssertionFailedRayDontMatch(Ray expected, Ray actual);

    uint256[] internal oneInArray;
    uint256 internal constant KEY = 0xA11CE;
    uint256 internal constant KEY2 = 0xB0B;
    address internal immutable signer;
    address internal immutable signer2;
    address internal constant BORROWER = address(bytes20(keccak256("borrower")));
    bytes4 internal immutable erc721SafeTransferFromSelector;
    bytes4 internal immutable erc721SafeTransferFromDataSelector;
    Money internal money;
    Money internal money2;
    NFT internal nft;
    NFT internal nft2;

    constructor() {
        oneInArray = new uint256[](1);
        oneInArray[0] = 1;
        signer = vm.addr(KEY);
        signer2 = vm.addr(KEY2);
        vm.label(BORROWER, "borrower");
        vm.label(signer, "signer");
        vm.label(signer2, "signer2");
        erc721SafeTransferFromSelector = getSelector("safeTransferFrom(address,address,uint256)");
        erc721SafeTransferFromDataSelector = getSelector("safeTransferFrom(address,address,uint256,bytes)");
    }

    function getOfferDigest(Offer memory offer) internal virtual returns (bytes32);

    function getSignatureFromKey(Offer memory offer, uint256 pKey) internal returns (bytes memory signature) {
        bytes32 digest = getOfferDigest(offer);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pKey, digest);
        signature = bytes.concat(r, s, bytes1(v));
    }

    function getSignature(Offer memory offer) internal returns (bytes memory signature) {
        return getSignatureFromKey(offer, KEY);
    }

    function getSignature2(Offer memory offer) internal returns (bytes memory signature) {
        return getSignatureFromKey(offer, KEY2);
    }

    function getCollateralState() internal view returns (CollateralState memory state) {
        return
            CollateralState({
                matched: Ray.wrap(0),
                assetLent: getOffer().assetToLend,
                minOfferDuration: getOffer().duration,
                from: BORROWER,
                nft: getOffer().collateral,
                loanId: 1
            });
    }

    function getOfferArg(Offer memory offer) internal returns (OfferArgs memory arg) {
        arg = OfferArgs({signature: getSignature(offer), amount: offer.loanToValue / 10, offer: offer});
    }

    function getOfferArgs(Offer memory offer) internal returns (OfferArgs[] memory) {
        OfferArgs[] memory ret = new OfferArgs[](1);
        ret[0] = getOfferArg(offer);
        return ret;
    }

    function getTranche(uint256 trancheId) internal virtual returns (Ray rate);

    function getLoan() internal returns (Loan memory) {
        Payment memory payment;
        return
            Loan({
                assetLent: getOffer().assetToLend,
                lent: 1 ether,
                shareLent: ONE,
                startDate: block.timestamp - 2 weeks,
                endDate: block.timestamp + 2 weeks,
                interestPerSecond: getTranche(0),
                borrower: BORROWER,
                collateral: getOffer().collateral,
                supplyPositionIndex: 1,
                payment: payment,
                nbOfPositions: 1
            });
    }

    function assertEq(Loan memory actual, Loan memory expected) internal view {
        if (keccak256(abi.encode(actual)) != keccak256(abi.encode(expected))) {
            logLoan(expected, "expected");
            logLoan(actual, "actual  ");
            revert AssertionFailedLoanDontMatch();
        }
    }

    function getOffer() internal view returns (Offer memory) {
        return
            Offer({
                assetToLend: money,
                loanToValue: 10 ether,
                duration: 2 weeks,
                expirationDate: block.timestamp + 2 hours,
                tranche: 0,
                collateral: NFToken({implem: nft, id: 1})
            });
    }

    function assertEq(Ray actual, Ray expected) internal pure {
        if (Ray.unwrap(actual) != Ray.unwrap(expected)) {
            revert AssertionFailedRayDontMatch(expected, actual);
        }
    }

    function getProvision() internal pure returns (Provision memory) {
        return Provision({amount: 1 ether, share: ONE, loanId: 1});
    }
}