// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import "@openzeppelin-upgrade/contracts/proxy/ClonesUpgradeable.sol";

import "../src/LotteryV1.sol";
import "../src/LotteryV2.sol";
import {BaseSetup} from "./BaseSetup.sol";
import {UUPSProxy} from "./utils/UUPSProxy.sol";

contract LotteryTest is BaseSetup {
    using ClonesUpgradeable for address;

    LotteryV1 public lottery1;
    LotteryV2 public lottery2;

    LotteryV1 public wrappedProxy1;
    LotteryV2 public wrappedProxy2;

    UUPSProxy public proxy;

    uint8 internal constant PROTOCOL_FEE = 10;
    uint8 internal constant RENTTOKEN_FEE = 80;
    uint256 internal constant RENT_AMOUNT = 1;
    uint256 internal constant WINNER_COUNT = 10;

    function setUp() public virtual override {
        BaseSetup.setUp();

        lottery1 = new LotteryV1();
        proxy = new UUPSProxy(address(lottery1), "");

        wrappedProxy1 = LotteryV1(address(proxy));

        wrappedProxy1.initialize(
            PROTOCOL_FEE,
            RENTTOKEN_FEE,
            RENT_AMOUNT,
            WINNER_COUNT
        );
    }

    function testCanInitialize() public {
        assertEq(wrappedProxy1.rentAmount(), RENT_AMOUNT);
    }

    function testCanUpgrade() public {
        lottery2 = new LotteryV2();
        wrappedProxy1.upgradeTo(address(lottery2));

        // re-wrap the proxy
        wrappedProxy2 = LotteryV2(address(proxy));

        assertEq(wrappedProxy2.rentAmount(), RENT_AMOUNT);

        wrappedProxy2.setPrizeNumber(200);
        assertEq(wrappedProxy2.prizeNumber(), 200);
    }
}
