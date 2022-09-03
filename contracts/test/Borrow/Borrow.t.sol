// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "../SetUp.sol";

error AssertionFailedLoanDontMatch();

contract TestBorrow is SetUp {
    using RayMath for Ray;

    function testSimpleNFTonReceived() public {
        uint256 tokenId = getTokens(signer);

        vm.startPrank(signer);

        bytes memory data = abi.encode(getOfferArgs(getOffer()));

        nft.safeTransferFrom(signer, address(nftaclp), tokenId, data);
    }

    function testWrongNFTAddress() public {
        IERC721 wrongNFT = IERC721(address(1));

        Offer memory offer = Offer({
                assetToLend: money,
                loanToValue: 10 ether,
                duration: 2 weeks,
                nonce: 0,
                collatSpecType: CollatSpecType.Floor,
                tranche: 0,
                collatSpecs: abi.encode(FloorSpec({
                    implem: wrongNFT
                }))
            });
        bytes memory data = abi.encode(getOfferArgs(offer));
        uint256 tokenId = getTokens(signer);

        vm.startPrank(signer);
        vm.expectRevert(abi.encodeWithSelector(
            NFTContractDoesntMatchOfferSpecs.selector,
            nft,
            wrongNFT
        ));
        nft.safeTransferFrom(signer, address(nftaclp), tokenId, data);
    }

    // should pass in a scenario as complex as possible
    // should borrow from 2 NFTs, one of which should borrow from 2 offers of different suppliers
    // use different cryptos for the 2 NFTs
    // NFT 1 : from collec1 with money1 with 2 suppliers
    // NFT 2 : from collec2 with money2 with 1 supplier
    // NFT 1 : 25% from supp1 at 2 eth valuation, 75% from supp2 at 1 eth val 
    function testComplexBorrow() public {
        BorrowArgs memory bargs1;
        BorrowArgs memory bargs2;
        OfferArgs memory oargs1;
        OfferArgs memory oargs2;
        OfferArgs memory oargs3;
        Offer memory signer1Offer1;
        Offer memory signer1Offer2;
        Offer memory signer2Offer;
        uint256 m1InitialBalance = money.balanceOf(address(this));
        uint256 m2InitialBalance = money2.balanceOf(address(this));

        vm.prank(signer);
        money.mint(2 ether);
        vm.prank(signer);
        money.approve(address(nftaclp), 2 ether);

        vm.prank(signer2);
        money.mint(2 ether);
        vm.prank(signer2);
        money.approve(address(nftaclp), 2 ether);

        vm.prank(signer);
        money2.mint(2 ether);
        vm.prank(signer);
        money2.approve(address(nftaclp), 2 ether);

        nft.approve(address(nftaclp), 1);
        nft2.approve(address(nftaclp), 1);

        signer1Offer1 = Offer({
            assetToLend: money,
            loanToValue: 2 ether,
            duration: 2 weeks,
            nonce: 0,
            collatSpecType: CollatSpecType.Single,
            tranche: 0,
            collatSpecs: abi.encode(NFToken({
                implem: nft,
                id: 1
            }))
        });

        signer1Offer2 = Offer({
            assetToLend: money2,
            loanToValue: 2 ether,
            duration: 4 weeks,
            nonce: 0,
            collatSpecType: CollatSpecType.Single,
            tranche: 0,
            collatSpecs: abi.encode(NFToken({
                implem: nft2,
                id: 1
            }))
        });

        signer2Offer = Offer({
            assetToLend: money,
            loanToValue: 1 ether,
            duration: 1 weeks,
            nonce: 0,
            collatSpecType: CollatSpecType.Floor,
            tranche: 0,
            collatSpecs: abi.encode(FloorSpec({
                implem: nft
            }))
        });

        {
            bytes32 hashSign1Off1 = keccak256(abi.encode(signer1Offer1));
            bytes32 hashSign1Off2 = keccak256(abi.encode(signer1Offer2));
            bytes32 hashSign2Off = keccak256(abi.encode(signer2Offer));
            Root memory rootSign1 = Root({root: keccak256(abi.encode(hashSign1Off1, hashSign1Off2))});
            Root memory rootSign2 = Root({root: hashSign2Off});
            // hashSign1Off1 < hashSign1Off2 = true
            bytes32[] memory proofSign1Off1 = new bytes32[](1);
            proofSign1Off1[0] = hashSign1Off2;
            bytes32[] memory proofSign1Off2 = new bytes32[](1);
            proofSign1Off2[0] = hashSign1Off1;
            bytes32[] memory proofSign2Off;
            oargs1 = OfferArgs({
                proof: proofSign1Off1,
                root: rootSign1,
                signature: getSignature(rootSign1),
                amount: 1 ether / 2, // 25%
                offer: signer1Offer1
            });

            oargs2 = OfferArgs({
                proof: proofSign2Off,
                root: rootSign2,
                signature: getSignature2(rootSign2),
                amount: 3 ether / 4, // 75%
                offer: signer2Offer
            });

            oargs3 = OfferArgs({
                proof: proofSign1Off2,
                root: rootSign1,
                signature: getSignature(rootSign1),
                amount: 2 ether, // 100%
                offer: signer1Offer2
            });
        }
        {
            OfferArgs[] memory offerArgs1 = new OfferArgs[](2);
            offerArgs1[0] = oargs1;
            offerArgs1[1] = oargs2;
            OfferArgs[] memory offerArgs2 = new OfferArgs[](1);
            offerArgs2[0] = oargs3;

            bargs1 = BorrowArgs({
                nft: NFToken({
                    implem: nft,
                    id: 1
                }),
                args: offerArgs1
            });
            
            bargs2 = BorrowArgs({
                nft: NFToken({
                    implem: nft2,
                    id: 1
                }),
                args: offerArgs2
            });
        }
        {
            BorrowArgs[] memory batchbargs = new BorrowArgs[](2);
            batchbargs[0] = bargs1;
            batchbargs[1] = bargs2;

            IBorrowFacet(address(nftaclp)).borrow(batchbargs);
        }
        assertEq(IERC721(address(nftaclp)).balanceOf(signer), 2);
        assertEq(IERC721(address(nftaclp)).balanceOf(signer2), 1);
        {
            Provision memory supp1pos1 = ISupplyPositionFacet(address(nftaclp)).position(1);
            Provision memory supp2pos = ISupplyPositionFacet(address(nftaclp)).position(2);
            Provision memory supp1pos2 = ISupplyPositionFacet(address(nftaclp)).position(3);
            assertEq(supp1pos1.amount, 1 ether / 2);
            assertEq(supp2pos.amount, 3 ether / 4);
            assertEq(supp1pos2.amount, 2 ether);
            assert(ONE.div(4).eq(supp1pos1.share));
            assert(ONE.div(4).mul(3).eq(supp2pos.share));
            assert(ONE.eq(supp1pos2.share));
        }
        // supplier money balances
        assertEq(money.balanceOf(signer), 1 ether / 2 * 3, "sig1 m1 bal pb");
        assertEq(money.balanceOf(signer2), 1 ether / 4 * 5, "sig2 m1 bal pb");
        assertEq(money2.balanceOf(signer), 0,  "sig1 m2 bal pb");
        
        // borrower money balances
        assertEq(money.balanceOf(address(this)), (1 ether / 4 * 5) + m1InitialBalance, "bor m1 bal pb");
        assertEq(money2.balanceOf(address(this)), (2 ether) + m2InitialBalance, "bor m2 bal pb");

        // nft balances
        assertEq(nft.balanceOf(address(this)), 0);
        assertEq(nft2.balanceOf(address(this)), 0);
        assertEq(nft.balanceOf(address(nftaclp)), 1);
        assertEq(nft.balanceOf(address(nftaclp)), 1);

        // loan
        {
            uint256[] memory supplyPositionIds1 = new uint256[](2);
            supplyPositionIds1[0] = 1;
            supplyPositionIds1[1] = 2;
            uint256[] memory supplyPositionIds2 = new uint256[](1);
            supplyPositionIds2[0] = 3;
            Loan memory loan1 = Loan({
                assetLent: money,
                lent: 1 ether / 4 * 5,
                endDate: block.timestamp + 1 weeks,
                tranche: 0,
                borrower: address(this),
                collateral: nft,
                tokenId: 1,
                repaid: 0,
                supplyPositionIds: supplyPositionIds1
            });
            Loan memory loan2 = Loan({
                assetLent: money2,
                lent: 2 ether,
                endDate: block.timestamp + 4 weeks,
                tranche: 0,
                borrower: address(this),
                collateral: nft2,
                tokenId: 1,
                repaid: 0,
                supplyPositionIds: supplyPositionIds2
            });
            assertEqL(loan1, IProtocolFacet(address(nftaclp)).getLoan(1));
            assertEqL(loan2, IProtocolFacet(address(nftaclp)).getLoan(2));
        }
    }

    // helpers

    function getOfferArgs(Offer memory offer) private returns(OfferArgs[] memory){
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

    function getTokens(address receiver) private returns(uint256 tokenId){
        vm.startPrank(receiver);

        tokenId = nft.mintOne();
        money.mint(100 ether);
        money.approve(address(nftaclp), 100 ether);

        vm.stopPrank();   
    }

    function getSignature(Root memory root) private returns(bytes memory signature){
        bytes32 digest = IBorrowFacet(address(nftaclp)).rootDigest(root);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(KEY, digest);
        signature = bytes.concat(r, s, bytes1(v));
    }

    function getSignature2(Root memory root) private returns(bytes memory signature){
        bytes32 digest = IBorrowFacet(address(nftaclp)).rootDigest(root);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(KEY2, digest);
        signature = bytes.concat(r, s, bytes1(v));
    }

    function getOffer() private view returns(Offer memory){
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

    function assertEqL(Loan memory actual, Loan memory expected) private view {
        if(keccak256(abi.encode(actual)) != keccak256(abi.encode(expected))) {
            logLoan(expected, "expected");
            logLoan(actual, "actual  ");
            revert AssertionFailedLoanDontMatch();
        }
    }

    // todo : test unknown collat spec type
    // todo : test multiple offers used for one NFT
}