import * as dotenv from "dotenv"
dotenv.config()
import { env } from "process"
import "@nomiclabs/hardhat-ethers"
import { HardhatUserConfig } from "hardhat/types"
import * as tdly from "@tenderly/hardhat-tenderly"

tdly.setup({ automaticVerifications: true })

const sepoliaRpc: string = env.SEPOLIA_URL as string
const goerliRpc: string = env.GOERLI_URL as string
const pKey: string = env.TEST_PKEY as string

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  paths: {
    sources: "./contracts/src"
  },
  networks: {
    sepolia: {
      url: sepoliaRpc,
      accounts: [pKey]
    },
    goerli: {
      url: goerliRpc,
      accounts: [pKey]
    }
  },
  tenderly: {
    project: "kairos-loan",
    username: "npasquie",
    privateVerification: true
  }
}

export default config
