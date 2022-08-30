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

/// @notice Arguments for the borrow parameters of an offer
/// @dev '-' means n^th
///     possible opti is to use OZ's multiProofVerify func, not used here
///     because it can mess with the ordering of the offer usage
/// @member proof - of the offer inclusion in his tree
/// @member root - of the supplier offer merkle tree
/// @member signature - of the supplier offer merkle tree root
/// @member amount - to borrow from this offer
/// @member offer intended for usage in the loan
struct OfferArgs {
    bytes32[] proof;
    Root root;
    bytes signature;
    uint256 amount;
    Offer offer;
}

/// @notice Data on collateral state during the matching process of a NFT
///     with multiple offers
/// @member matched proportion from 0 to 1 of the collateral value matched by offers
/// @member assetLent - ERC20 that the protocol will send as loan
/// @member minOfferDuration minimal duration among offers used
/// @member from original owner of the nft
/// @member nft the collateral asset
struct CollateralState {
    Ray matched;
    IERC20 assetLent;
    uint256 minOfferDuration;
    address from;
    NFToken nft;
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

/// @title Non Fungible Token
/// @notice describes an ERC721 compliant token
/// @member implem address of the NFT contract
/// @member id token identifier
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

// supply position facet storage //

struct SupplyPosition {
    string name;
    string symbol;
    uint256 totalSupply;
    mapping(uint256 => address) owner;
    mapping(address => uint256) balance;
    mapping(uint256 => address) tokenApproval;
    mapping(address => mapping(address => bool)) operatorApproval;
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
bytes32 constant SUPPLY_POSITION_SP = keccak256("eth.nftaclp.supply-position");

uint256 constant RAY = 1e27;
Ray constant ONE = Ray.wrap(RAY);

/* solhint-disable func-visibility */

function protocolStorage() pure returns (Protocol storage protocol) {
    bytes32 position = PROTOCOL_SP;
    /* solhint-disable-next-line no-inline-assembly */
    assembly {
        protocol.slot := position
    }
}

function supplyPositionStorage() pure returns (SupplyPosition storage sp) {
    bytes32 position = SUPPLY_POSITION_SP;
    /* solhint-disable-next-line no-inline-assembly */
    assembly {
        sp.slot := position
    }
}