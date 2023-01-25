import { deployFacet } from "./deploy"

const facetNames = ["BetaSettersFacet"]

async function main() {
  for (const facetName of facetNames) {
    await deployFacet(facetName)
  }
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
