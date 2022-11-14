// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "../../DataStructure/Global.sol";
import "generated/proof.sol";

contract Verify is Test {
    using MerkleProof for bytes32[];

    function testVerif() public pure {
        bytes32[] memory proof = abi.decode(PROOF, (bytes32[]));
        Offer memory offer = Offer({
            assetToLend: IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F),
            loanToValue: 12,
            duration: 12,
            expirationDate: 0,
            collatSpecType: CollatSpecType.Floor,
            tranche: 0,
            collatSpecs: abi.encode(FloorSpec({implem: IERC721(0x1A92f7381B9F03921564a437210bB9396471050C)}))
        });
        require(proof.verify(ROOT, keccak256(abi.encode(offer))), "");
    }
}
