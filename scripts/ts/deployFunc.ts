import { Contract as depContract } from "ethers"
import { ethers } from "hardhat"

const blockConfirmations = 3
const ierc165SupportsInterfaceSelector = "0x01ffc9a7"
const facetNames = [
  "DiamondCutFacet",
  "DiamondLoupeFacet",
  "OwnershipFacet",
  "RepayFacet",
  "BorrowFacet",
  "SupplyPositionFacet",
  "ProtocolFacet",
  "AuctionFacet",
  "ClaimFacet"
]

const {
  getSelectors,
  FacetCutAction
  // eslint-disable-next-line @typescript-eslint/no-var-requires
} = require("diamond/scripts/libraries/diamond.js") // must keep as require

// adapted from https://github.com/mudgen/diamond-1-hardhat/blob/main/scripts/deploy.js

interface FacetCut {
  facetAddress: string
  action: string
  functionSelectors: string[]
}

interface DiamondArgs {
  owner: string
  init: string
  initCalldata: string
}

let supplyPositionFacetAddress: string
let facetCuts: FacetCut[] = []

export async function deploy(name: string, arg?: [FacetCut[], DiamondArgs]): Promise<depContract> {
  const ToDeploy = await ethers.getContractFactory(name)

  let toDeploy
  if (arg) {
    toDeploy = await ToDeploy.deploy(...arg)
  } else {
    toDeploy = await ToDeploy.deploy()
  }
  await toDeploy.deployed()
  await toDeploy.deployTransaction.wait(blockConfirmations)
  if (name === "SupplyPositionFacet") {
    supplyPositionFacetAddress = toDeploy.address
  }
  return toDeploy
}

export async function deployFacet(name: string) {
  const facet = await deploy(name)
  await facet.deployTransaction.wait(blockConfirmations)
  facetCuts.push({
    facetAddress: facet.address,
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(facet)
  })
}

export async function deployKairos() {
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

  facetCuts = facetCuts.map((cut: FacetCut) => {
    const ret = { ...cut }
    if (cut.facetAddress === supplyPositionFacetAddress) {
      ret.functionSelectors = cut.functionSelectors.filter((selector: string) => {
        return selector !== ierc165SupportsInterfaceSelector
      })
    }
    return ret
  })

  deploy("Diamond", [facetCuts, diamondArgs])
}
