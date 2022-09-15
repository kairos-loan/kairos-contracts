// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../SupplyPositionLogic/SafeMint.sol";
import "../interface/IDCHelperFacet.sol";
import "./Constructor.sol";

contract TestCommons is Constructor, SafeMint {
    function publicStoreLoan(Loan memory loan, uint256 loanId) public {
        protocolStorage().loan[loanId] = loan;
    }

    function publicStoreProvision(Provision memory provision, uint256 positionId) public {
        supplyPositionStorage().provision[positionId] = provision;
    }

    function publicMintPosition(address to, Provision memory provision) public returns(uint256 tokenId) {
        tokenId = safeMint(to, provision);
    }

    function store(Loan memory loan, uint256 loanId) internal {
        IDCHelperFacet(address(nftaclp)).delegateCall(
            address(this), 
            abi.encodeWithSelector(this.publicStoreLoan.selector, loan, loanId));
    }

    function store(Provision memory provision, uint256 positionId) internal {
        IDCHelperFacet(address(nftaclp)).delegateCall(
            address(this), 
            abi.encodeWithSelector(this.publicStoreProvision.selector, provision, positionId));
    }

    function mintPosition(address to, Provision memory provision) internal returns(uint256 tokenId) {
        bytes memory data = IDCHelperFacet(address(nftaclp)).delegateCall(
            address(this), 
            abi.encodeWithSelector(this.publicMintPosition.selector, to, provision));
        tokenId = abi.decode(data, (uint256));
    }

    function getDefaultLoan() internal view returns(Loan memory) {
        uint256[] memory uint256Array = new uint256[](1);
        uint256Array[0] = 1;
        return Loan({
            assetLent: money,
            lent: 1 ether,
            shareLent: ONE,
            startDate: block.timestamp - 2 weeks,
            endDate: block.timestamp + 2 weeks,
            interestPerSecond: protocolStorage().tranche[0],
            borrower: signer,
            collateral: nft,
            tokenId: 1,
            repaid: 0,
            supplyPositionIds: uint256Array,
            borrowerClaimed: false,
            liquidated: false
        });
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

    function getDefaultProvision() internal pure returns(Provision memory) {
        return Provision({
            amount: 1 ether,
            share: ONE,
            loanId: 1
        });
    }

    function getRootOfTwoHashes(bytes32 hashOne, bytes32 hashTwo) internal pure returns(Root memory ret){
        ret.root = hashOne < hashTwo 
            ? keccak256(abi.encode(hashOne, hashTwo)) 
            : keccak256(abi.encode(hashTwo, hashOne));
    }
}