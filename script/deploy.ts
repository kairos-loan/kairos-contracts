import { ethers } from "hardhat"
const {
  getSelectors,
  FacetCutAction
} = require("diamond/scripts/libraries/diamond.js") // must keep as require

// adapted from https://github.com/mudgen/diamond-1-hardhat/blob/main/scripts/deploy.js

let supplyPositionFacetAddress: string
const ierc165SupportsInterfaceSelector = "0x01ffc9a7"
const facetNames = [
  "DiamondCutFacet",
  "DiamondLoupeFacet",
  "OwnershipFacet",
  "RepayFacet",
  "BorrowFacet",
  "SupplyPositionFacet",
  "ProtocolFacet"
]
let facetCuts: any = []

export async function deploy(name: string, arg?: Array<any>) {
  const ToDeploy = await ethers.getContractFactory(name)

  let toDeploy
  if (arg) {
    toDeploy = await ToDeploy.deploy(...arg)
  } else {
    toDeploy = await ToDeploy.deploy()
  }
  await toDeploy.deployed()
  if (name === "SupplyPositionFacet") {
    supplyPositionFacetAddress = toDeploy.address
  }
  return toDeploy
}

async function deployFacet(name: string) {
  const facet = await deploy(name)
  facetCuts.push({
    facetAddress: facet.address,
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(facet)
  })
}

async function main() {
  const [deployer] = await ethers.getSigners()

  const init = await deploy("Initializer")
  for (const facetName of facetNames) {
    await deployFacet(facetName)
  }
  const initCall = init.interface.encodeFunctionData("init")
  const diamondArgs = {
    owner: deployer.address,
    init: init.address,
    initCalldata: initCall
  }

  facetCuts = facetCuts.map((cut: any) => {
    let ret = { ...cut }
    if (cut.facetAddress === supplyPositionFacetAddress) {
      ret.functionSelectors = cut.functionSelectors.filter(
        (selector: string) => {
          return selector !== ierc165SupportsInterfaceSelector
        }
      )
    }
    return ret
  })

  deploy("Diamond", [facetCuts, diamondArgs])
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
