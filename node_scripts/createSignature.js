const ethers = require("ethers");
const domain = {
  name: "Polypus",
  version: "1",
  chainId: 1,
  verifyingContract: "0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC",
};
const types = {
  ComplexNumber: [
    { name: "realPart", type: "uint256" },
    { name: "imaginaryPart", type: "uint256" },
  ],
  TwoNumbers: [
    { name: "firstNumber", type: "ComplexNumber" },
    { name: "secondNumber", type: "ComplexNumber" },
  ],
};
const value = {
  firstNumber: {
    realPart: "10",
    imaginaryPart: "20",
  },
  secondNumber: {
    realPart: "10",
    imaginaryPart: "20",
  },
};

async function main() {
  let signer = ethers.Wallet.createRandom();
  let signature = await signer._signTypedData(domain, types, value);
  console.log(signature);
}

main();
