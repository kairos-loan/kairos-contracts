// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {console} from "forge-std/console.sol";

import {RayMath} from "../../src/utils/RayMath.sol";
import {BorrowArg, CollateralState, NFToken, Offer, OfferArg} from "../../src/DataStructure/Objects.sol";
import {getSelector} from "../../src/utils/FuncSelectors.h.sol";
import {Loan, Payment, Provision, Auction} from "../../src/DataStructure/Storage.sol";
import {Loggers} from "./Loggers.sol";
import {Money} from "../../src/mock/Money.sol";
import {NFT} from "../../src/mock/NFT.sol";
import {ONE} from "../../src/DataStructure/Global.sol";
import {Ray} from "../../src/DataStructure/Objects.sol";

abstract contract TestCommons is Loggers {
    using RayMath for Ray;

    Ray internal immutable apr40percent;

    error AssertionFailedLoanDontMatch();
    error AssertionFailedRayDontMatch(Ray expected, Ray actual);
    error AssertionFailedCollatStateDontMatch();

    uint256[] internal oneInArray;
    uint256[] internal emptyArray;
    bytes internal emptyBytes;
    uint256 internal constant KEY = 0xA11CE;
    uint256 internal constant KEY2 = 0xB0B;
    address internal immutable signer;
    address internal immutable signer2;
    address internal constant BORROWER = address(bytes20(keccak256("borrower")));
    address internal constant OWNER = address(bytes20(keccak256("owner")));
    bytes4 internal immutable erc721SafeTransferFromSelector;
    bytes4 internal immutable erc721SafeTransferFromDataSelector;
    Money internal money;
    Money internal money2;
    NFT internal nft;
    NFT internal nft2;

    constructor() {
        apr40percent = ONE.div(10).mul(4).div(365 days);
        oneInArray = new uint256[](1);
        oneInArray[0] = 1;
        signer = vm.addr(KEY);
        signer2 = vm.addr(KEY2);
        vm.label(BORROWER, "borrower");
        vm.label(OWNER, "owner");
        vm.label(signer, "signer");
        vm.label(signer2, "signer2");
        erc721SafeTransferFromSelector = getSelector("safeTransferFrom(address,address,uint256)");
        erc721SafeTransferFromDataSelector = getSelector("safeTransferFrom(address,address,uint256,bytes)");
        if (block.timestamp < 365 days) {
            vm.warp(365 days);
        }
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
                tranche: 0,
                minOfferDuration: getOffer().duration,
                from: BORROWER,
                nft: getOffer().collateral,
                loanId: 1
            });
    }

    function getOfferArg() internal returns (OfferArg memory) {
        return getOfferArg(getOffer());
    }

    function getOfferArg(Offer memory offer) internal returns (OfferArg memory arg) {
        arg = OfferArg({signature: getSignature(offer), amount: offer.loanToValue / 10, offer: offer});
    }

    function getOfferArgs() internal returns (OfferArg[] memory) {
        return getOfferArgs(getOffer());
    }

    function getOfferArgs(Offer memory offer) internal returns (OfferArg[] memory) {
        OfferArg[] memory ret = new OfferArg[](1);
        ret[0] = getOfferArg(offer);
        return ret;
    }

    /// @notice to modify the default offer, but not the collateral
    function getBorrowArgs(Offer memory offer) internal returns (BorrowArg[] memory) {
        BorrowArg[] memory args = new BorrowArg[](1);
        args[0] = BorrowArg({nft: getNft(), args: getOfferArgs(offer)});
        return args;
    }

    function getBorrowArgs() internal returns (BorrowArg[] memory) {
        return getBorrowArgs(getOffer());
    }

    function getNft() internal view returns (NFToken memory ret) {
        ret = NFToken({implem: nft, id: 1});
    }

    function getTranche(uint256 trancheId) internal view virtual returns (Ray rate);

    function getAuction() internal pure returns (Auction memory) {
        return Auction({duration: 3 days, priceFactor: ONE.mul(3)});
    }

    /// @dev created as override helper, to modify only few elements in loan
    function _getLoan() internal view returns (Loan memory) {
        Payment memory payment;
        return
            Loan({
                assetLent: getOffer().assetToLend,
                lent: 1 ether,
                shareLent: ONE,
                startDate: block.timestamp - 2 weeks,
                endDate: block.timestamp + 2 weeks,
                auction: getAuction(),
                interestPerSecond: getTranche(0),
                borrower: BORROWER,
                collateral: getOffer().collateral,
                supplyPositionIndex: 1,
                payment: payment,
                nbOfPositions: 1
            });
    }

    function getLoan() internal view virtual returns (Loan memory) {
        return _getLoan();
    }

    function assertEq(Loan memory actual, Loan memory expected) internal view {
        if (keccak256(abi.encode(actual)) != keccak256(abi.encode(expected))) {
            logLoan(expected, "expected");
            logLoan(actual, "actual  ");
            revert AssertionFailedLoanDontMatch();
        }
    }

    function assertEq(CollateralState memory actual, CollateralState memory expected) internal view {
        if (keccak256(abi.encode(actual)) != keccak256(abi.encode(expected))) {
            logCollateralState(expected, "expected");
            logCollateralState(actual, "actual  ");
            revert AssertionFailedCollatStateDontMatch();
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
                collateral: getNft()
            });
    }

    function assertEq(Ray actual, Ray expected) internal view {
        if (Ray.unwrap(actual) != Ray.unwrap(expected)) {
            console.log("expected ", Ray.unwrap(expected));
            console.log("actual   ", Ray.unwrap(actual));
            revert AssertionFailedRayDontMatch(expected, actual);
        }
    }

    function getProvision() internal pure returns (Provision memory) {
        return Provision({amount: 1 ether, share: ONE, loanId: 1});
    }
}
