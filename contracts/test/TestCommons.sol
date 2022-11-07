// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../SupplyPositionLogic/SafeMint.sol";
import "../interface/IDCHelperFacet.sol";
import "./TestConstructor.sol";

contract TestCommons is TestConstructor, SafeMint {
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
        IDCHelperFacet(address(kairos)).delegateCall(
            address(this), 
            abi.encodeWithSelector(this.publicStoreLoan.selector, loan, loanId));
    }

    function store(Provision memory provision, uint256 positionId) internal {
        IDCHelperFacet(address(kairos)).delegateCall(
            address(this), 
            abi.encodeWithSelector(this.publicStoreProvision.selector, provision, positionId));
    }

    function mintPosition(address to, Provision memory provision) internal returns(uint256 tokenId) {
        bytes memory data = IDCHelperFacet(address(kairos)).delegateCall(
            address(this), 
            abi.encodeWithSelector(this.publicMintPosition.selector, to, provision));
        tokenId = abi.decode(data, (uint256));
    }

    function getSignatureFromKey(
        Root memory root, 
        uint256 pKey, 
        IKairos kairos
    ) internal returns(bytes memory signature){
        bytes32 digest = kairos.rootDigest(root);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pKey, digest);
        signature = bytes.concat(r, s, bytes1(v));
    }

    function getSignature(Root memory root) internal returns(bytes memory signature){
        return getSignatureFromKey(root, KEY, kairos);
    }

    function getSignature2(Root memory root) internal returns(bytes memory signature){
        return getSignatureFromKey(root, KEY2, kairos);
    }

    function getOfferArgs(Offer memory offer) internal returns(OfferArgs[] memory){
        OfferArgs[] memory offerArgs = new OfferArgs[](1);
        Root memory root = Root({root: keccak256(abi.encode(offer))});
        bytes32[] memory emptyArray;
        offerArgs[0] = OfferArgs({
            proof: emptyArray,
            root: root,
            signature: getSignature(root),
            amount: 1 ether,
            offer: offer
        });
        return offerArgs;
    }



    function getTokens() internal returns(uint256 tokenId){


        vm.prank(signer);
        uint tokenId = nft.mintOne();
        vm.prank(signer);
        money.mint(100 ether);
        vm.prank(signer);
        money.approve(address(kairos), 100 ether);


        return tokenId;



    }
    function getTokens2() internal returns(uint256 tokenId){


        vm.prank(signer2);
        uint tokenId = nft2.mintOne();
        console.log(tokenId);
        vm.prank(signer2);
        money.mint(100 ether);
        vm.prank(signer2);
        money.approve(address(kairos), 100 ether);


        return tokenId;



    }

    function getDefaultLoan() internal view returns(Loan memory) {
        Payment memory payment;
        return Loan({
            assetLent: money,
            lent: 1 ether,
            shareLent: ONE,
            startDate: block.timestamp - 2 weeks,
            endDate: block.timestamp + 2 weeks,
            interestPerSecond: protocolStorage().tranche[0],
            borrower: signer,
            collateral: NFToken({
                implem: nft,
                id: 1
            }),
            supplyPositionIndex: 1,
            payment: payment,
            nbOfPositions: 1
        });
    }

    function  getMultipleLoan(uint  x) internal view returns(Loan[] memory){
        Payment memory payment;

    Loan[] memory loans = new Loan[](x-1);

        for(uint  i; i < x-1; i++){
            loans[i]=
                Loan({
                    assetLent: money,
                    lent: 1 ether,
                    shareLent: ONE,
                    startDate: block.timestamp - 2 weeks,
                    endDate: block.timestamp + 2 weeks,
                    interestPerSecond: protocolStorage().tranche[0],
                    borrower: signer,
                    collateral: NFToken({
                        implem: nft,
                        id: i
                    }),
                    supplyPositionIndex: i,
                    payment: payment,
                    nbOfPositions: uint8(x)
                });
        }
        return loans;

    }


    function assertEq(Loan memory actual, Loan memory expected) internal view {
        if(keccak256(abi.encode(actual)) != keccak256(abi.encode(expected))) {
            logLoan(expected, "expected");
            logLoan(actual, "actual  ");
            revert AssertionFailedLoanDontMatch();
        }
    }

    function getOffer() internal view returns(Offer memory){
        return Offer({
                assetToLend: money,
                loanToValue: 10 ether,
                duration: 2 weeks,
                nonce: 0,
                collatSpecType: CollatSpecType.Floor,
                tranche: 0,
                collatSpecs: abi.encode(FloorSpec({
                    implem: nft
                }))
            });
    }

    function getMulptipleNft(uint x) internal returns(uint[] memory){
        uint[] memory nftsId = new uint[](x);
        for (uint i = 0; i<x; i++){
            uint nftId = nft.mintOne();
            nftsId[i]= nftId;
        }

        return nftsId;
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