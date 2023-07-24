// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "forge-std/Script.sol";
import "../src/LotteryV1.sol";
import {UUPSProxy} from "../test/utils/UUPSProxy.sol";

contract Lottery is Script {
    uint8 internal constant PROTOCOL_FEE = 10;
    uint8 internal constant RENTTOKEN_FEE = 80;
    uint256 internal constant RENT_AMOUNT = 3;
    uint256 internal constant WINNER_COUNT = 10;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        LotteryV1 lottery1 = new LotteryV1();
        UUPSProxy proxy = new UUPSProxy(address(lottery1), new bytes(0));

        LotteryV1 wrappedProxy1 = LotteryV1(address(proxy));

        wrappedProxy1.initialize(
            PROTOCOL_FEE,
            RENTTOKEN_FEE,
            RENT_AMOUNT,
            WINNER_COUNT,
            0xEE86283a2DFCc1f52E86790e275e5b07b44A50E5
        );

        vm.stopBroadcast();
    }
}
