// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {Script} from "forge-std/Script.sol";

import {DCHelperFacet} from "../test/Commons/DCHelperFacet.sol";
import {DCTarget} from "../test/Commons/DCTarget.sol";
import {Diamond, DiamondArgs} from "diamond/contracts/Diamond.sol";
import {External} from "../test/Commons/External.sol";
import {IKairos} from "../interface/IKairos.sol";
import {Money} from "../src/mock/Money.sol";
import {NFT} from "../src/mock/NFT.sol";
import {Offer} from "../src/DataStructure/Objects.sol";
import {Loan, Provision} from "../src/DataStructure/Storage.sol";

/// @dev deploy script intended for local testing
contract DeployLocal is Script, External {
    address internal deployer;
    address internal supplier;
    uint256 internal constant TEST_KEY =
        uint256(bytes32(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80));
    address payable internal frontTester;

    constructor() {
        deployer = vm.addr(TEST_KEY);
        supplier = vm.addr(KEY);
        frontTester = payable(vm.envAddress("FRONT_TEST_ADDR"));
    }

    /// @notice gives & approve 100 money tokens and 1 nft to the deployer
    /* solhint-disable-next-line function-max-lines */
    function run() public {
        string memory toWrite = "{\n";
        vm.deal(deployer, 1000 ether);

        vm.startBroadcast(TEST_KEY);

        // for front testing
        helper = new DCHelperFacet();
        dcTarget = new DCTarget();
        toWrite = addConst(toWrite, "frontTestAddr", vm.toString(frontTester));
        frontTester.transfer(10 ether);
        NFT frontNft = new NFT("Test Doodles", "TDood");
        frontNft.mintOneTo(frontTester);
        frontNft.mintOneTo(frontTester); // mint doodle #2 as well
        toWrite = addConst(toWrite, "testDoodlesAddr", vm.toString(address(frontNft)));
        frontNft = new NFT("Test Azukis", "TAzuk");
        frontNft.setBaseURI(
            "https://ikzttp.mypinata.cloud/ipfs/QmQFkLSQysj94s5GvTHPyzTxrawwtjgiiYS2TBLgrvw8CW/"
        );
        frontNft.mintOneTo(frontTester);
        toWrite = addConst(toWrite, "testAzukisAddr", vm.toString(address(frontNft)));
        frontNft = new NFT("Test mfers", "TMfer");
        frontNft.mintOneTo(frontTester);
        toWrite = addConst(toWrite, "testMfersAddr", vm.toString(address(frontNft)));
        frontNft.setBaseURI("ipfs://QmWiQE65tmpYzcokCheQmng2DCM33DEhjXcPB6PanwpAZo/");
        // end for front testing

        createContracts();
        DiamondArgs memory args = DiamondArgs({
            owner: deployer,
            init: address(initializer),
            initCalldata: abi.encodeWithSelector(initializer.init.selector)
        });
        kairos = IKairos(address(new Diamond(getFacetCuts(), args)));
        kairos.diamondCut(testFacetCuts(), address(0), emptyBytes); // enables testing
        money = new Money();
        nft = new NFT("Test NFTs", "TNFT");
        Offer memory offer = getOffer();

        money.mint(100 ether);
        money.mint(100 ether, frontTester);
        money.approve(address(kairos), 100 ether);
        nft.mintOne();
        nft.approve(address(kairos), 1);
        populateFrontLoans(frontNft);

        vm.stopBroadcast();

        toWrite = addConst(toWrite, "dcTargetAddr", vm.toString(address(dcTarget)));
        toWrite = addConst(toWrite, "kairosAddr", vm.toString(address(kairos)));
        toWrite = addConst(toWrite, "signature", vm.toString(getSignature(offer)));
        toWrite = addConst(toWrite, "moneyAddr", vm.toString(address(money)));
        toWrite = addConst(toWrite, "offerExpirationDate", vm.toString(offer.expirationDate));
        toWrite = addConst(toWrite, "nftAddr", vm.toString(address(nft)));
        toWrite = addConst(toWrite, "supplierAddr", vm.toString(supplier));
        toWrite = addLastConst(toWrite, "deployerAddr", vm.toString(deployer));
        toWrite = string.concat(toWrite, "}");
        vm.writeFile("./packages/shared/src/generated/deployment.json", toWrite);
    }

    function mintLoan(Loan memory loan) internal returns (uint256 loanId) {
        bytes memory data = DCHelperFacet(address(kairos)).delegateCall(
            address(dcTarget),
            abi.encodeWithSelector(dcTarget.mintLoan.selector, loan)
        );
        loanId = abi.decode(data, (uint256));
    }

    function populateFrontLoans(NFT frontNft) internal {
        Provision memory provision = getProvision();
        provision.loanId = 1;
        Loan memory loan = getLoan();
        loan.supplyPositionIndex = mintPosition(deployer, provision);
        loan.collateral.id = frontNft.mintOneTo(address(kairos));
        loan.borrower = frontTester;
        provision.loanId = mintLoan(loan) + 1;
        loan.supplyPositionIndex = mintPosition(deployer, provision);
        loan.collateral.id = frontNft.mintOneTo(address(kairos));
        provision.loanId = mintLoan(loan) + 1;
    }

    /* solhint-disable quotes */

    function addConst(
        string memory written,
        string memory name,
        string memory const
    ) internal pure returns (string memory toWrite) {
        toWrite = string.concat(written, ' "');
        toWrite = string.concat(toWrite, name);
        toWrite = string.concat(toWrite, '": "');
        toWrite = string.concat(toWrite, const);
        toWrite = string.concat(toWrite, '",\n');
    }

    function addLastConst(
        string memory written,
        string memory name,
        string memory const
    ) internal pure returns (string memory toWrite) {
        toWrite = string.concat(written, ' "');
        toWrite = string.concat(toWrite, name);
        toWrite = string.concat(toWrite, '": "');
        toWrite = string.concat(toWrite, const);
        toWrite = string.concat(toWrite, '"\n');
    }
}
