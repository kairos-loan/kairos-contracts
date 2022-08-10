const ethers = require("ethers");
const domain = {
  name: "Polypus",
  version: "1",
  chainId: 1,
  verifyingContract: "0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC",
};
const types = {
  Lol: [{ name: "lol", type: "uint256" }],
};
const value = {
  lol: "1",
};

async function main() {
  let signer = ethers.Wallet.createRandom();
  let signature = await signer._signTypedData(domain, types, value);
  console.log(signature);
}

main();
