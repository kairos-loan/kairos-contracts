// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "../../DataStructure.sol";

// goal of this experiment is to gen the same proofs as with merkletreejs but in solidity
// currently not in development

// contract TreeGen is Test {
//     function test1() public pure {
//         Offer memory offer1 = Offer({
//             assetToLend: IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F),
//             loanToValue: 12,
//             duration: 12,
//             nonce: 0,
//             collatSpecType: CollatSpecType.Floor,
//             tranche: 0,
//             collatSpecs: abi.encode(FloorSpec({
//                 collateral: IERC721(0x1A92f7381B9F03921564a437210bB9396471050C)
//             }))
//         });

//         Offer memory offer2 = offer1;
//         Offer memory offer3 = offer1;

//         offer2.duration = 13;
//         offer3.duration = 14;

//         bytes[3] memory leafs = [
//             abi.encode(offer1),
//             abi.encode(offer2),
//             abi.encode(offer3)
//         ];
//     }
// }