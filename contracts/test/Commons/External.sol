// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "contracts/interface/IKairos.sol";
import "./TestCommons.sol";
import "./DCHelperFacet.sol";
import "contracts/ContractsCreator.sol";
import "contracts/interface/IDCHelperFacet.sol";
import "./DCTarget.sol";

contract External is TestCommons, ContractsCreator {
    IKairos internal kairos;
    DCHelperFacet internal helper;
    DCTarget internal dcTarget;

    constructor() {
        createContracts();
        helper = new DCHelperFacet();
        dcTarget = new DCTarget();
    }

    function store(Loan memory loan, uint256 loanId) internal {
        IDCHelperFacet(address(kairos)).delegateCall(
            address(dcTarget),
            abi.encodeWithSelector(dcTarget.storeLoan.selector, loan, loanId)
        );
    }

    function store(Provision memory provision, uint256 positionId) internal {
        IDCHelperFacet(address(kairos)).delegateCall(
            address(dcTarget),
            abi.encodeWithSelector(dcTarget.storeProvision.selector, provision, positionId)
        );
    }

    function mintPosition(address to, Provision memory provision) internal returns (uint256 tokenId) {
        bytes memory data = IDCHelperFacet(address(kairos)).delegateCall(
            address(dcTarget),
            abi.encodeWithSelector(dcTarget.mintPosition.selector, to, provision)
        );
        tokenId = abi.decode(data, (uint256));
    }

    function getTokens(address receiver) internal returns (uint256 tokenId) {
        vm.startPrank(receiver);

        tokenId = nft.mintOne();
        money.mint(100 ether);
        money.approve(address(kairos), 100 ether);

        vm.stopPrank();
    }

    /// @dev use only in TestCommons
    function getOfferDigest(Offer memory offer) internal view override returns (bytes32) {
        return kairos.offerDigest(offer);
    }

    /// @dev use only in TestCommons
    function getTranche(uint256 trancheId) internal view override returns (Ray rate) {
        return kairos.getRateOfTranche(trancheId);
    }
}
