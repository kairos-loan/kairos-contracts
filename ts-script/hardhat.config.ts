import * as dotenv from "dotenv"
import { env } from "process"
import "@typechain/hardhat"
import "@nomiclabs/hardhat-ethers"
import * as tdly from "@tenderly/hardhat-tenderly"
import { HardhatUserConfig } from "hardhat/types/config"
dotenv.config()

tdly.setup({ automaticVerifications: true })

// DEV : Always access scripts and tests depending on hardhat through npx hardhat <...>

const sepoliaRpc: string = env.SEPOLIA_URL as string
const goerliRpc: string = env.GOERLI_URL as string
const pKey: string = env.TEST_PKEY as string

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.17",
    settings: {
      viaIR: true
    }
  },
  paths: {
    sources: "./packages/contracts/src",
    cache: "./out/hh/cache",
    artifacts: "./out/hh/artifacts"
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
  },
  typechain: {
    target: "ethers-v5",
    outDir: "./out/hh/typechain"
  }
}

export default config
