// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

import "./SetUp.sol";

/// @dev inherit from this contract to perform tests from OUTSIDE kairos
contract External is SetUp, ERC721Holder {
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

    function getFlooz(address to, Money moula) internal {
        getFlooz(to, moula, 100 ether);
    }

    function getFlooz(address to, Money moula, uint256 amount) internal {
        vm.startPrank(to);
        moula.mint(amount);
        moula.approve(address(kairos), amount);
        vm.stopPrank();
    }

    function getJpeg(address to, NFT implem) internal returns (uint256 tokenId) {
        tokenId = implem.mintOneTo(to);
        vm.prank(to);
        implem.approve(address(kairos), tokenId);
    }
}