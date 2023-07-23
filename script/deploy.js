const { ethers, upgrades } = require("hardhat");

async function main() {

    //deploy lotteryV1
    const LotteryV1Factory = await ethers.getContractFactory("LotteryV1");
    lotteryV1 = await upgrades.deployProxy(
        LotteryV1Factory,
        [10, 80, 3, 10, 0xEE86283a2DFCc1f52E86790e275e5b07b44A50E5],
        { initializer: "initialize", kind: "uups" }
    );
    await lotteryV1.deployed();

    //upgrade to lottery
    const LotteryV2Factory = await ethers.getContractFactory("LotteryV2");
    lottery = await upgrades.upgradeProxy(lotteryV1, LotteryV2Factory, {
        gasLimit: 30000000,
    });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});