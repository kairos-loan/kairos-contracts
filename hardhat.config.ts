import "@nomiclabs/hardhat-ethers"
import * as tdly from "@tenderly/hardhat-tenderly"
import "@typechain/hardhat"
import * as dotenv from "dotenv"
import { HardhatUserConfig } from "hardhat/types/config"
import { env } from "process"

dotenv.config({ path: "../../.env" })

tdly.setup({ automaticVerifications: true })

// DEV : Always access scripts and tests depending on hardhat through npx hardhat <...>

const sepoliaRpc: string = env.SEPOLIA_URL as string
const goerliRpc: string = env.GOERLI_URL as string
const pKey: string = env.DEPLOYER_KEY as string

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.17",
    settings: {
      // viaIR: true, // removed bc tenderly verif chokes
      optimizer: {
        enabled: true,
        runs: 1000
      }
    }
  },
  paths: {
    sources: "./src",
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
    },
    local: {
      url: "http://127.0.0.1:8545",
      accounts: [
        "ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
      ]
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
