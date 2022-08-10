// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "./interface/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error UnknownCollatSpecType(CollatSpecType);
error NFTContractDoesntMatchOfferSpecs(IERC721 sentCollat, IERC721 offerCollat);
error CollateralDoesntMatchSpecs(IERC721 sentCollateral, uint256 tokenId);

uint256 constant RAY = 1e27;
uint256 constant WAD = 1 ether;

/// @notice type ids for collateral specification
/// @member Floor any NFT in a collection is accepted
enum CollatSpecType { Floor }

/// @notice 27-decimals fixed point unsigned number
type Ray is uint256;

/// @notice General protocol
/// @member rateOfTranche interest rate of tranche of provided id, in multiplier per second
struct Protocol {
    mapping(uint256 => Ray) rateOfTranche;
    uint256 nbOfLoans;
    mapping(uint256 => Loan) loan;
}

/// @notice Loan offer
/// @member assetToLend address of the ERC-20 to lend
/// @member loanToValue amount to lend per collateral unit
/// @member duration in seconds, time before mandatory repayment after loan start
/// @member nonce used to determine if the offer is still valid
/// @member collateralSpecType identifies logic to establish validity of an asset
/// @member tranche identifies the interest rate tranche
/// @member collateralSpecs abi-encoded arguments for the validity checker
struct Offer {
    IERC20 assetToLend;
    uint256 loanToValue;
    uint256 duration;
    uint256 nonce;
    CollatSpecType collatSpecType;
    uint256 tranche;
    bytes collatSpecs;
}

/// @dev Add "Spec" as suffix to structs meant for describing collaterals

/// @notice Collateral type accepting any NFT of a collection
/// @member collateral NFT contract I.e collection
struct FloorSpec {
    IERC721 collateral;
}

/// @notice Issued Loan (corresponding to one collateral)
/// @member assetLent currency lent
/// @member lent total amount lent
/// @member endDate timestamp after which sale starts & repay is impossible
/// @member tranche identifies the interest rate tranche
/// @member borrower borrowing account
/// @member collateral NFT contract of collateral
/// @member tokenId identifies the collateral in his collection
/// @member nbOfSuppliers number of suppliers
/// @member matchedOffer matched offer by id
/// @member suppliedBy amount supplied 
struct Loan {
    IERC20 assetLent;
    uint256 lent;
    uint256 endDate;
    uint256 tranche;
    address borrower;
    IERC721 collateral;
    uint256 tokenId;
    uint256 nbOfSuppliers;
    mapping(uint256 => Offer) matchedOffer;
    mapping(uint256 => uint256) suppliedBy;
}

bytes32 constant PROTOCOL_SP = keccak256("eth.nftaclp.protocol");

/* solhint-disable func-visibility */

function configStorage() pure returns (Protocol storage protocol) {
    bytes32 position = PROTOCOL_SP;
    /* solhint-disable-next-line no-inline-assembly */
    assembly {
        protocol.slot := position
    }
}