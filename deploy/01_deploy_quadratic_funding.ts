import {HardhatRuntimeEnvironment} from "hardhat/types"
import {DeployFunction} from "hardhat-deploy/types"
import {verifyContracts} from "../utils/verify"
import { QuadraticFunding} from "../utils";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const {deployments, getNamedAccounts, network} = hre
    const {deploy} = deployments
    const {deployer} = await getNamedAccounts()

    let constructorArguments = [
        '0x1cDC2A4fF8d374D91a1161C142cc496FBF5547Ec',
        '0x1cDC2A4fF8d374D91a1161C142cc496FBF5547Ec',
        '0x1cDC2A4fF8d374D91a1161C142cc496FBF5547Ec'
    ]

    const deployResult = await deploy(QuadraticFunding, {
        from: deployer,
        args: constructorArguments,
        log: true
    })

    if (network.live) {
        await verifyContracts(
            hre,
            deployResult,
            constructorArguments,
            `contracts/${QuadraticFunding}.sol:${QuadraticFunding}`
        )
    }
}

func.tags = [QuadraticFunding, "1.0.0"]
func.id = QuadraticFunding
export default func