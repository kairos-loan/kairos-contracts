// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "./DataStructure/Global.sol";
import "./utils/RayMath.sol";
import "./interface/ISupplyPositionFacet.sol";

// todo : docs

contract AuctionFacet {
    using RayMath for Ray;
    using RayMath for uint256;

    event Buy(uint256 indexed loanId, IERC721 indexed collection, uint256 indexed tokenId);

    function buy(BuyArgs[] memory args) external {
        for (uint8 i; i < args.length; i++) {
            useLoan(args[i]);
        }
    }

    // todo : implement use of startId + number
    // todo : implement internal lib for supplyPositionFacet manipulation as opti
    // todo : update to approvedOrOwner
    function useLoan(BuyArgs memory args) internal {
        Protocol storage proto = protocolStorage();
        SupplyPosition storage sp = supplyPositionStorage();
        Loan storage loan = proto.loan[args.loanId];
        Ray shareToPay = ONE;
        if (args.to == loan.borrower) {
            loan.borrowerClaimed = true;
            shareToPay = loan.shareLent;    
        }
        uint256 timeSinceLiquidable = loan.endDate - block.timestamp; // reverts if asset is not yet liquidable
        uint256 toPay;
        Provision storage provision;
        address positionOwner;

        loan.liquidated = true;
        if (loan.repaid != 0) { revert LoanAlreadyRepaid(args.loanId); }
        for (uint8 i; i < args.positionIds.length; i++) {
            provision = sp.provision[args.positionIds[i]];
            shareToPay = shareToPay.sub(provision.share);
            positionOwner = ISupplyPositionFacet(address(this)).ownerOf(args.positionIds[i]);
            if (msg.sender != positionOwner){
                revert NotOwnerOfTheSupplyPosition(args.positionIds[i], positionOwner);
            }
            if (provision.loanId != args.loanId) {
                revert SupplyPositionDoesntBelongToTheLoan(args.positionIds[i], args.loanId);
            }
            ISupplyPositionFacet(address(this)).burn(args.positionIds[i]);
        }
        toPay = price(loan.lent, loan.shareLent, timeSinceLiquidable).mul(shareToPay);
        loan.assetLent.transferFrom(msg.sender, address(this), toPay);
        loan.repaid = toPay;
        loan.collateral.safeTransferFrom(address(this), args.to, loan.tokenId);

        emit Buy(args.loanId, loan.collateral, loan.tokenId);
    }

    /// @notice gets price calculated following a linear dutch auction
    function price(uint256 lent, Ray shareLent, uint256 timeElapsed) internal view returns(uint256) {
        Protocol storage proto = protocolStorage();

        // todo : explore attack vectors based on small values messing with calculus
        uint256 loanToValue = lent.div(shareLent);
        uint256 initialPrice = loanToValue.mul(proto.auctionPriceFactor);
        Ray decreasingFactor = timeElapsed >= proto.auctionDuration ? ZERO : timeElapsed.div(proto.auctionDuration);
        return initialPrice.mul(decreasingFactor);
    }
}