// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {Script} from "forge-std/Script.sol";

import {DCHelperFacet} from "../../test/Commons/DCHelperFacet.sol";
import {DCTarget} from "../../test/Commons/DCTarget.sol";
import {Diamond, DiamondArgs} from "diamond/contracts/Diamond.sol";
import {External} from "../../test/Commons/External.sol";
import {IKairos} from "../../src/interface/IKairos.sol";
import {Money} from "../../src/mock/Money.sol";
import {NFT} from "../../src/mock/NFT.sol";
import {Offer, NFToken, BuyArg} from "../../src/DataStructure/Objects.sol";
import {Loan, Provision} from "../../src/DataStructure/Storage.sol";

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
        string memory toWrite = "";
        vm.deal(deployer, 1000 ether);

        vm.startBroadcast(TEST_KEY);

        // for front testing
        helper = new DCHelperFacet();
        dcTarget = new DCTarget();
        frontTester.transfer(10 ether);
        NFT frontNft = new NFT("Test Doodles", "TDood");
        frontNft.mintOneTo(frontTester);
        frontNft.mintOneTo(frontTester); // mint doodle #2 as well
        toWrite = addEnv(toWrite, "NFT_ADDR1", vm.toString(address(frontNft)));
        frontNft = new NFT("Test Azukis", "TAzuk");
        frontNft.setBaseURI(
            "https://ikzttp.mypinata.cloud/ipfs/QmQFkLSQysj94s5GvTHPyzTxrawwtjgiiYS2TBLgrvw8CW/"
        );
        frontNft.mintOneTo(frontTester);
        toWrite = addEnv(toWrite, "NFT_ADDR2", vm.toString(address(frontNft)));
        frontNft = new NFT("Test mfers", "TMfer");
        frontNft.mintOneTo(frontTester);
        toWrite = addEnv(toWrite, "NFT_ADDR3", vm.toString(address(frontNft)));
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

        toWrite = addEnv(toWrite, "DC_TARGET_ADDR", vm.toString(address(dcTarget)));
        toWrite = addEnv(toWrite, "KAIROS_ADDR", vm.toString(address(kairos)));
        toWrite = addEnv(toWrite, "SIGNATURE", vm.toString(getSignature(offer)));
        toWrite = addEnv(toWrite, "WETH_ADDR", vm.toString(address(money)));
        toWrite = addEnv(toWrite, "OFFER_EXPIRATION_DATE", vm.toString(offer.expirationDate));
        toWrite = addEnv(toWrite, "TEST_NFT_ADDR", vm.toString(address(nft)));
        toWrite = addEnv(toWrite, "SUPPLIER_ADDR", vm.toString(supplier));
        toWrite = addEnv(toWrite, "DEPLOYER_ADDR", vm.toString(deployer));
        vm.writeFile("./out/deployment.env", toWrite);
    }

    function mintLoan(Loan memory loan) internal returns (uint256 loanId) {
        bytes memory data = DCHelperFacet(address(kairos)).delegateCall(
            address(dcTarget),
            abi.encodeWithSelector(dcTarget.mintLoan.selector, loan)
        );
        loanId = abi.decode(data, (uint256));
    }

    function updateLoanPositionAndCollateral(
        Provision memory provision,
        Loan memory loan,
        NFT nft
    ) internal returns (Loan memory) {
        loan.supplyPositionIndex = mintPosition(deployer, provision);
        loan.collateral = NFToken({id: nft.mintOneTo(address(kairos)), implem: nft});
        return loan;
    }

    function populateFrontLoans(NFT frontNft) internal {
        Provision memory provision = getProvision();
        provision.loanId = 1;
        Loan memory loan = getLoan();
        loan.borrower = frontTester;

        loan = updateLoanPositionAndCollateral(provision, loan, frontNft);
        provision.loanId = mintLoan(loan) + 1; // mfer 2 active to repay in 2 weeks

        loan = updateLoanPositionAndCollateral(provision, loan, frontNft);
        provision.loanId = mintLoan(loan) + 1; // mfer 3 active to repay in 2 weeks

        loan = updateLoanPositionAndCollateral(provision, loan, frontNft);
        uint256[] memory toRepayLoanIds = new uint256[](1);
        toRepayLoanIds[0] = mintLoan(loan); // mfer 4 repaid loan
        provision.loanId = toRepayLoanIds[0] + 1;
        kairos.repay(toRepayLoanIds); // repaid by deployer on behalf of borrower

        loan.startDate = block.timestamp - 2 weeks;
        loan.endDate = block.timestamp - 1 days;
        loan = updateLoanPositionAndCollateral(provision, loan, frontNft);
        provision.loanId = mintLoan(loan) + 1; // mfer 5 in active auction

        loan = updateLoanPositionAndCollateral(provision, loan, frontNft);
        uint256 toLiquidateLoanId = mintLoan(loan);
        BuyArg[] memory buyArgs = new BuyArg[](1);
        buyArgs[0] = BuyArg({loanId: toLiquidateLoanId, to: frontTester, positionIds: emptyArray});
        kairos.buy(buyArgs); // mfer 6 liquidated (and collateral given back to front tester)
    }

    /* solhint-disable quotes */

    function addEnv(
        string memory written,
        string memory name,
        string memory const
    ) internal pure returns (string memory toWrite) {
        toWrite = string.concat(written, name);
        toWrite = string.concat(toWrite, "=");
        toWrite = string.concat(toWrite, const);
        toWrite = string.concat(toWrite, "\n");
    }
}
