import {HardhatUserConfig} from "hardhat/config"
import "hardhat-deploy"
import "@nomicfoundation/hardhat-toolbox"
import {
  CMC_API_KEY,
  DEPLOYER_PRIVATE_KEY,
  ETHERSCAN_ETH_API_KEY,
  ETHERSCAN_POLYGON_API_KEY,
  REPORT_GAS,
  RPC_URL_ETHEREUM,
  RPC_URL_GOERLI,
  RPC_URL_MUMBAI,
  RPC_URL_SEPOLIA
} from "./utils/constants"
import "@nomiclabs/hardhat-ethers"
import "@nomiclabs/hardhat-etherscan"
import "solidity-coverage"
import "hardhat-abi-exporter"
import "hardhat-gas-reporter"

const notworkConfig: any = {
  hardhat: {
    chainId: 1337
  }
}

if (DEPLOYER_PRIVATE_KEY) {
  notworkConfig["goerli"] = {
    url: RPC_URL_GOERLI,
    chainId: 5,
    accounts: [DEPLOYER_PRIVATE_KEY]
  }

  notworkConfig["sepolia"] = {
    url: RPC_URL_SEPOLIA,
    chainId: 11155111,
    accounts: [DEPLOYER_PRIVATE_KEY]
  }

  notworkConfig["mumbai"] = {
    url: RPC_URL_MUMBAI,
    chainId: 80001,
    accounts: [DEPLOYER_PRIVATE_KEY]
  }

  notworkConfig["ethereum"] = {
    url: RPC_URL_ETHEREUM,
    chainId: 1,
    accounts: [DEPLOYER_PRIVATE_KEY]
  }
}

const namedAccounts = {
  deployer: {
    default: 0
  },
  defaultAdmin: {
    default: 0,
    5: "0xCF0e3F9380860Fff07c2D625f55Df420EB1BBBd9",
    11155111: "0x1cDC2A4fF8d374D91a1161C142cc496FBF5547Ec",
    80001: "0x1cDC2A4fF8d374D91a1161C142cc496FBF5547Ec",
    1: "0xCF0e3F9380860Fff07c2D625f55Df420EB1BBBd9"
  },
  platformFeeRecipient: {
    default: 0,
    5: "0xCF0e3F9380860Fff07c2D625f55Df420EB1BBBd9",
    11155111: "0x1cDC2A4fF8d374D91a1161C142cc496FBF5547Ec",
    80001: "0x1cDC2A4fF8d374D91a1161C142cc496FBF5547Ec",
    1: "0xCF0e3F9380860Fff07c2D625f55Df420EB1BBBd9"
  },
  broadcaster: {
    default: 0,
    5: "0xCF0e3F9380860Fff07c2D625f55Df420EB1BBBd9",
    1155111: "0x980003F1361083f7BB21aAa74E0B19fe98bB84A8",
    80001: "0x1cDC2A4fF8d374D91a1161C142cc496FBF5547Ec",
    1: "0xCF0e3F9380860Fff07c2D625f55Df420EB1BBBd9"
  }
}

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.19",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      }
    ]
  },
  networks: notworkConfig,
  namedAccounts: namedAccounts,
  etherscan: {
    apiKey: {
      goerli: ETHERSCAN_ETH_API_KEY,
      sepolia: ETHERSCAN_ETH_API_KEY,
      mainnet: ETHERSCAN_ETH_API_KEY,
      mumbai: ETHERSCAN_POLYGON_API_KEY
    },
    customChains: [
      {
        network: "mumbai",
        chainId: 80001,
        urls: {
          apiURL: "https://api-testnet.polygonscan.com/api",
          browserURL: "https://mumbai.polygonscan.com/"
        }
      }
    ]
  },
  abiExporter: {
    runOnCompile: true,
    flat: true,
    only: ["Founds"],
    spacing: 2,
    pretty: true
  },
  gasReporter: {
    currency: "USD",
    excludeContracts: [],
    token: "ETH",
    noColors: true,
    gasPriceApi: `https://api.etherscan.io/api?module=proxy&action=eth_gasPrice&apikey=${ETHERSCAN_ETH_API_KEY}`,
    coinmarketcap: CMC_API_KEY,
    enabled: REPORT_GAS
  }
}

export default config