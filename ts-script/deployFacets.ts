import { deployFacet } from "./deployFunc"

const facetNames = ["AuctionFacet", "BorrowFacet"]

async function main() {
  for (const facetName of facetNames) {
    await deployFacet(facetName)
  }
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
