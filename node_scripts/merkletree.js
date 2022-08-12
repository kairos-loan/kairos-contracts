const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");
// const fs = require("fs");
const ethers = require("ethers");

async function main() {
  let abicoder = new ethers.utils.AbiCoder();
  let OfferString =
    "tuple(address assetToLend, uint256 loanToValue, uint256 duration, uint256 nonce, uint8 collatSpecType, uint256 tranche, bytes collatSpecs) Offer";
  let FloorSpecString = "tuple(address collateral) FloorSpec";

  let floorValue1 = [
    {
      collateral: "0x1A92f7381B9F03921564a437210bB9396471050C",
    },
  ];

  let floorValue1Coded = abicoder.encode([FloorSpecString], floorValue1);

  let offerValue1 = {
    assetToLend: "0x6B175474E89094C44Da98b954EedeAC495271d0F",
    loanToValue: 12,
    duration: 12,
    nonce: 0,
    collatSpecType: 0,
    tranche: 0,
    collatSpecs: floorValue1Coded,
  };

  let offerValue2 = { ...offerValue1 };
  offerValue2.duration = 13;
  let offerValue3 = { ...offerValue1 };
  offerValue3.duration = 14;

  let offer1Coded = abicoder.encode([OfferString], [offerValue1]);
  let offer2Coded = abicoder.encode([OfferString], [offerValue2]);
  let offer3Coded = abicoder.encode([OfferString], [offerValue3]);

  let leafs = [offer1Coded, offer2Coded, offer3Coded];

  let tree = new MerkleTree(leafs, keccak256, {
    sortPairs: true,
    hashLeaves: true,
  });
  console.log(tree);

  //   console.log(offer1Coded);
}

main();
