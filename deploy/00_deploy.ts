import {HardhatRuntimeEnvironment} from "hardhat/types"
import {DeployFunction} from "hardhat-deploy/types"
import {verifyContracts} from "../utils/verify"
import {FOUNDS} from "../utils";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const {deployments, getNamedAccounts, network} = hre
    const {deploy} = deployments
    const {deployer} = await getNamedAccounts()

    const deployResult = await deploy(FOUNDS, {
        from: deployer,
        log: true
    })

    if (network.live) {
        await verifyContracts(
            hre,
            deployResult,
            [],
            `contracts/${FOUNDS}.sol:${FOUNDS}`
        )
    }
}

func.tags = [FOUNDS, "1.0.0"]
func.id = FOUNDS
export default func