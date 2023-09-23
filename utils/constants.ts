const dotenv = require("dotenv")
dotenv.config()

export type ProviderType = "DEFAULT" | "INFURA" | "ALCHEMY"

export const DEPLOYER_PRIVATE_KEY = process.env.DEPLOYER_PRIVATE_KEY || ""
export const ETHERSCAN_ETH_API_KEY = process.env.ETHERSCAN_ETH_API_KEY || ""
export const ETHERSCAN_POLYGON_API_KEY = process.env.ETHERSCAN_POLYGON_API_KEY || ""
export const INFURA_ID_GOERLI = process.env.INFURA_ID

export const ALCHEMY_API_KEY_GOERLI = process.env.ALCHEMY_API_KEY
export const ALCHEMY_API_KEY_SEPOLIA = process.env.ALCHEMY_API_KEY_SEPOLIA
export const ALCHEMY_API_KEY_MUMBAI = process.env.ALCHEMY_API_KEY_MUMBAI
export const ALCHEMY_API_KEY_ETHEREUM = process.env.ALCHEMY_API_KEY_ETHEREUM


export const REPORT_GAS = false

export const SELECTED_PROVIDER: ProviderType =
    (INFURA_ID_GOERLI && "INFURA") || (ALCHEMY_API_KEY_GOERLI && "ALCHEMY") || "DEFAULT"

export const PROVIDER_MAP = {
    INFURA: `https://goerli.infura.io/v3/${INFURA_ID_GOERLI}`,
    ALCHEMY: `https://eth-goerli.g.alchemy.com/v2/${ALCHEMY_API_KEY_GOERLI}`,
    DEFAULT: "https://goerli.infura.io/v3/"
}
export const RPC_URL_GOERLI = PROVIDER_MAP[SELECTED_PROVIDER]
export const RPC_URL_SEPOLIA = `https://eth-sepolia.g.alchemy.com/v2/${ALCHEMY_API_KEY_SEPOLIA}`
export const RPC_URL_ETHEREUM = `https://eth-mainnet.g.alchemy.com/v2/${ALCHEMY_API_KEY_ETHEREUM}`
export const RPC_URL_MUMBAI = `https://polygon-mumbai.g.alchemy.com/v2/${ALCHEMY_API_KEY_MUMBAI}`
export const CMC_API_KEY = process.env.CMC_API_KEY