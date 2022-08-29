// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "./interface/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error UnknownCollatSpecType(CollatSpecType);
error NFTContractDoesntMatchOfferSpecs(IERC721 sentCollat, IERC721 offerCollat);
error TokenIdDoesntMatchOfferSpecs(uint256 sentTokenId, uint256 offerTokenId);
error CollateralDoesntMatchSpecs(IERC721 sentCollateral, uint256 tokenId);
error OfferNotFound(Offer offer, Root merkleTreeRoot);
error OfferHasBeenDeleted(Offer offer, uint256 currentSupplierNonce);
error RequestedAmountTooHigh(uint256 requested, uint256 offered);
error InconsistentAssetRequests(IERC20 firstRequested, IERC20 requested);

/// @notice type ids for collateral specification
/// @member Floor any NFT in a collection is accepted
enum CollatSpecType { Floor, Single }

/// @notice 27-decimals fixed point unsigned number
type Ray is uint256;

// ~~~ structs not meant for storage ~~~ //

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
/// @dev we use struct with a single member to keep the type check on
///     collateral being an IERC721
/// @member collateral NFT contract I.e collection
struct FloorSpec {
    IERC721 collateral;
}

/// @notice Collateral type accepting one specific NFT
/// @member tokenId token identifier
/// @member collateral NFT contract I.e collection
struct SingleSpec {
    uint256 tokenId;
    IERC721 collateral;
}

/// @notice Root of a supplier offer merkle tree
/// @dev we use a struct with a single member to sign in the EIP712 fashion
///     so signed roots are only available for the desired contract on desired chain
/// @member root the merkle root
struct Root {
    bytes32 root;
}

struct NFToken {
    IERC721 implem;
    uint256 id;
}

// ~~~ structs used in storage ~~~ //

/// @notice General protocol
/// @member rateOfTranche interest rate of tranche of provided id, in multiplier per second
struct Protocol {
    mapping(uint256 => Ray) rateOfTranche;
    uint256 nbOfLoans;
    mapping(uint256 => Loan) loan;
    mapping(address => uint256) supplierNonce;
}

/// @notice Issued Loan (corresponding to one collateral)
/// @member assetLent currency lent
/// @member lent total amount lent
/// @member endDate timestamp after which sale starts & repay is impossible
/// @member tranche identifies the interest rate tranche
/// @member borrower borrowing account
/// @member collateral NFT contract of collateral
/// @member tokenId identifies the collateral in his collection
/// @member provisions abi encoded Provision[] sources of lent liquidity 
///         struct memory copy to storage is a solc unimplemented feature
struct Loan {
    IERC20 assetLent;
    uint256 lent;
    uint256 endDate;
    uint256 tranche;
    address borrower;
    IERC721 collateral;
    uint256 tokenId;
    bytes provisions;
}

/// @title data on a liquidity provision from a supply offer in one existing loan
/// @member supplier provider of liquidity
/// @member amount - supplied for this provision
/// @member share - of the collateral matched by this provision
struct Provision {
    address supplier;
    uint256 amount;
    // Ray share; // useful ?
}

bytes32 constant ROOT_TYPEHASH = keccak256("Root(bytes32 root)");

bytes32 constant PROTOCOL_SP = keccak256("eth.nftaclp.protocol");

uint256 constant RAY = 1e27;
Ray constant ONE = Ray.wrap(RAY);
// uint256 constant WAD = 1 ether;

/* solhint-disable func-visibility */

function protocolStorage() pure returns (Protocol storage protocol) {
    bytes32 position = PROTOCOL_SP;
    /* solhint-disable-next-line no-inline-assembly */
    assembly {
        protocol.slot := position
    }
}