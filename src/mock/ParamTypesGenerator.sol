// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Loan} from "../DataStructure/Storage.sol";
import {NFToken, Offer, OfferArg} from "../DataStructure/Objects.sol";

/* solhint-disable no-empty-blocks */

/// @notice this contract purpose is to be picked up by typechain to generate
///     ethers ParamTypes from its functions
contract ParamTypesGenerator {
    function offerParam(Offer memory offer) external {}

    function nftParam(NFToken memory nft) external {}

    function loanParam(Loan memory loan) external {}

    function offerArgArrParam(OfferArg[] memory args) external {}
}
