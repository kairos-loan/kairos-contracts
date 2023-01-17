import { deploy } from "./deploy"

async function main() {
  await deploy("NFT", ["TestNft", "TNFT"]) // todo modify names and deploy 3 nft collecs
  await deploy("Money")
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
