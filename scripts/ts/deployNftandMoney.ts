import { NFT } from "@kairos-loan/chain-types"
import { deploy } from "./deployFunc"

async function main() {
  await deploy("NFT", ["Kairos Test Doodles", "K-DOOD"])
  const azuk = (await deploy("NFT", ["Kairos Test Azukis", "K-AZUK"])) as NFT
  const azukMetaTx = await azuk.setBaseURI(
    "https://ikzttp.mypinata.cloud/ipfs/QmQFkLSQysj94s5GvTHPyzTxrawwtjgiiYS2TBLgrvw8CW/"
  )
  await azukMetaTx.wait(6)
  const mfers = (await deploy("NFT", ["Kairos Test Mfers", "K-MFER"])) as NFT
  const mferMetaTx = await mfers.setBaseURI(
    "ipfs://QmWiQE65tmpYzcokCheQmng2DCM33DEhjXcPB6PanwpAZo/"
  )
  await mferMetaTx.wait(6)
  await deploy("TestCurrency", ["Kairos Loan Beta Fake WEth", "KWETH"])
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
