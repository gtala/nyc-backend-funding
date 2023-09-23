import {HardhatRuntimeEnvironment} from "hardhat/types"
import {DeployFunction} from "hardhat-deploy/types"
import {verifyContracts} from "../utils/verify"
import {CampaignContract} from "../utils";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const {deployments, getNamedAccounts, network} = hre
    const {deploy} = deployments
    const {deployer} = await getNamedAccounts()

    const deployResult = await deploy(CampaignContract, {
        from: deployer,
        log: true
    })

    if (network.live) {
        await verifyContracts(
            hre,
            deployResult,
            [],
            `contracts/${CampaignContract}.sol:${CampaignContract}`
        )
    }
}

func.tags = [CampaignContract, "1.0.0"]
func.id = CampaignContract
export default func