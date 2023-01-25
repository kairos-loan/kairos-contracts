import { deployFacet } from "./deploy"

const facetNames = ["ClaimFacet"]

async function main() {
  for (const facetName of facetNames) {
    await deployFacet(facetName)
  }
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
