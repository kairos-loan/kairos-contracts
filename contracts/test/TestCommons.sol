// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "../BorrowLogic/BorrowCheckers.sol";
import "../interface/ISupplyPositionFacet.sol";

contract TestCommons is Test {
    uint256 internal constant KEY = 0xA11CE;
    uint256 internal constant KEY2 = 0xB0B;
    address internal immutable signer;
    address internal immutable signer2;

    constructor() {
        signer = vm.addr(KEY);
        signer2 = vm.addr(KEY2);
        vm.label(signer, "signer");
        vm.label(signer2, "signer2");
    }

    function logLoan(Loan memory loan, string memory name) internal view {
        console.log("~~~~~~~ start loan ", name, " ~~~~~~~");
        console.log("assetLent           ", address(loan.assetLent));
        console.log("lent                ", loan.lent);
        console.log("endDate             ", loan.endDate);
        console.log("tranche             ", loan.tranche);
        console.log("borrower            ", loan.borrower);
        console.log("collateral          ", address(loan.collateral));
        console.log("tokenId             ", loan.tokenId);
        console.log("repaid              ", loan.repaid);
        for(uint256 i; i < loan.supplyPositionIds.length; i++) {
            console.log("supplyPositionIds %s: %s", i, loan.supplyPositionIds[i]);
        }
        console.log("~~~~~~~ end  loan ", name, " ~~~~~~~");
    }
}