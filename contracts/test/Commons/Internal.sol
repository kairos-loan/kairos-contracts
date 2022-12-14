// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./TestCommons.sol";
import "./BigKairos.sol";

/// @dev inherit from this contract to perform tests from INSIDE kairos
contract Internal is TestCommons, BigKairos {
    using RayMath for Ray;

    constructor() {
        bytes memory randoCode = hex"01";

        protocolStorage().tranche[0] = ONE.div(10).mul(4).div(365 days); // 40% APR
        money = Money(address(bytes20(keccak256("mock address money"))));
        vm.etch(address(money), randoCode);
        vm.label(address(money), "money");
        money2 = Money(address(bytes20(keccak256("mock address money2"))));
        vm.etch(address(money2), randoCode);
        vm.label(address(money2), "money2");
        nft = NFT(address(bytes20(keccak256("mock address nft"))));
        vm.etch(address(nft), randoCode);
        vm.label(address(nft), "nft");
        nft2 = NFT(address(bytes20(keccak256("mock address nft2"))));
        vm.etch(address(nft2), randoCode);
        vm.label(address(nft2), "nft2");
    }

    function useOfferExternal(
        OfferArgs memory args,
        CollateralState memory collatState
    ) external returns (CollateralState memory) {
        return useOffer(args, collatState);
    }

    function checkOfferArgsExternal(OfferArgs memory args) external view returns (address) {
        return checkOfferArgs(args);
    }

    function useCollateralExternal(OfferArgs[] memory args, address from, NFToken memory nft)external returns (Loan memory loan){
        loan = useCollateral(args, from, nft);
    }

    function checkCollateralExternal(Offer memory offer, NFToken memory providedNft) external pure {
        checkCollateral(offer, providedNft);
    }


    function sendInterestsExternal(Loan storage loan, Provision storage provision) internal returns(uint256 sent){
        sent = sendInterests(loan, provision);
    }
    function sendShareOfSaleAsSupplierExternal(Loan storage loan, Provision storage provision) internal returns(uint256 sent){
        sent = sendShareOfSaleAsSupplier(loan, provision);
    }

    /// @dev use only in TestCommons
    function getOfferDigest(Offer memory offer) internal view override returns (bytes32) {
        return offerDigest(offer);
    }


    function priceI(uint256 lent, Ray shareLent, uint256 timeElapsed) internal view returns (uint256 res) {
        res = price(lent, shareLent, timeElapsed);
    }

    /*

    function storeInternal(Loan memory loan, uint256 loanId) internal {
        IDCHelperFacet(address(kairos)).delegateCall(
            address(dcTarget),
            abi.encodeWithSelector(dcTarget.storeLoan.selector, loan, loanId)
        );
    }


    function storeInternal(Provision memory provision, uint256 positionId) internal {
        IDCHelperFacet(address(kairos)).delegateCall(
            address(dcTarget),
            abi.encodeWithSelector(dcTarget.storeProvision.selector, provision, positionId)
        );
    }
    */


    /// @dev use only in TestCommons
    function getTranche(uint256 trancheId) internal view override returns (Ray rate) {
        return protocolStorage().tranche[trancheId];
    }
}
