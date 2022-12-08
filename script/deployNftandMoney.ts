import { deploy } from "./deploy"

async function main() {
  await deploy("NFT", ["TestNft", "TNFT"])
  await deploy("Money")
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
