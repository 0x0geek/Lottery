// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "forge-std/Script.sol";
import "../src/LotteryV1.sol";
import "../src/LotteryV2.sol";
import {UUPSProxy} from "../test/utils/UUPSProxy.sol";

contract Lottery is Script {
    uint8 internal constant PROTOCOL_FEE = 10;
    uint8 internal constant RENTTOKEN_FEE = 80;
    uint32 internal constant WINNER_COUNT = 10;
    uint256 internal constant RENT_AMOUNT = 3;

    LotteryV1 wrappedProxy1;
    LotteryV2 wrappedProxy2;
    UUPSProxy proxy;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        LotteryV1 lottery1 = new LotteryV1();
        proxy = new UUPSProxy(address(lottery1), "");

        wrappedProxy1 = LotteryV1(address(proxy));

        wrappedProxy1.initialize(
            PROTOCOL_FEE,
            RENTTOKEN_FEE,
            WINNER_COUNT,
            RENT_AMOUNT,
            0xEE86283a2DFCc1f52E86790e275e5b07b44A50E5
        );

        LotteryV2 lottery2 = new LotteryV2();
        wrappedProxy1.upgradeTo(address(lottery2));

        // re-wrap the proxy
        wrappedProxy2 = LotteryV2(address(proxy));

        // Once upgrade is finished, check if the new function is working fine.
        wrappedProxy2.setPrizeAmount(200);

        vm.stopBroadcast();
    }
}
