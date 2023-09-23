import {DeployResult} from "hardhat-deploy/types"
import {HardhatRuntimeEnvironment} from "hardhat/types"
import "@nomiclabs/hardhat-etherscan"

export async function verifyContracts(
  hre: HardhatRuntimeEnvironment,
  deployResult: DeployResult,
  constructorArguments: string[] = [],
  pathContract: string | undefined = undefined
) {
  // @ts-ignore
  const {deployments} = hre
  const {log} = deployments

  const configVerify = {
    address: deployResult.address,
    constructorArguments: constructorArguments,
    contract: pathContract
  }

  //remove element with null | undefined value
  const configVerifyResult = Object.fromEntries(Object.entries(configVerify).filter(([_, v]) => v != null))
  log(`Starting verification of ${configVerify.address}`)

  let networkName = hre.network.name
  if (networkName === "ethereum") networkName = "mainnet"

  // @ts-ignore
  const verifyApiKey = hre.config.etherscan?.apiKey[networkName]
  if (!verifyApiKey) console.warn("No Etherscan API Found. Contract will not verify")
  else {
    try {
      await hre.run("verify:verify", configVerifyResult)
    } catch (err: any) {
      if (
        err.message.includes("Reason: Already Verified") ||
        err.message.includes("Contract source code already verified")
      ) {
        log("Contract is already verified!")
      } else throw err
    }
  }
}