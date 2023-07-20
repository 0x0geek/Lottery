// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import "@openzeppelin-upgrade/contracts/proxy/ClonesUpgradeable.sol";

import "../src/LotteryV1.sol";
import "../src/LotteryV2.sol";
import {BaseSetup} from "./BaseSetup.sol";
import {UUPSProxy} from "./utils/UUPSProxy.sol";
import {MerkleTree} from "./MerkleTree.sol";

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

        wrappedProxy2.setPrizeAmount(200);
        assertEq(wrappedProxy2.prizeAmount(), 200);
        assertEq(wrappedProxy2.protocolFee(), PROTOCOL_FEE);
    }

    // function testGenerateMerkleTree() public {
    //     uint256 length = users.length;

    //     address[] memory whitelistUsers = new address[](length);

    //     for (uint256 i; i != length; ++i) {
    //         whitelistUsers[i] = users[i];
    //     }

    //     MerkleTree merkleTree = new MerkleTree(whitelistUsers);

    //     assertEq(
    //         merkleTree.getRoot(),
    //         0x8dbc2bdf5655b07f404dd2fb7dc9a85ecf58436257795789a8548e228881b36d
    //     );
    // }

    // function getMerkleTreeRoot() private returns (bytes32) {
    //     uint256 length = users.length;

    //     address[] memory whitelistUsers = new address[](length);

    //     for (uint256 i; i != length; ++i) {
    //         whitelistUsers[i] = users[i];
    //     }

    //     MerkleTree merkleTree = new MerkleTree(whitelistUsers);
    //     bytes32 rootHash = merkleTree.getRoot();

    //     assertEq(
    //         rootHash,
    //         0x8dbc2bdf5655b07f404dd2fb7dc9a85ecf58436257795789a8548e228881b36d
    //     );

    //     return rootHash;
    // }

    // function testIntegration() public {
    //     bytes32 rootHash = getMerkleTreeRoot();

    //     wrappedProxy1.startLottery(rootHash);

    //     vm.startPrank(alice);
    //     bytes32[] memory data = new bytes32[](2);
    //     data[
    //         0
    //     ] = 0x0bd8c9c2ec12639173b58f716b945909988d63d0d61b99ce5356b80b1443238c;
    //     data[
    //         1
    //     ] = 0x7a71af3d21c3235c7f81420b8427f9f166d08e5b1e11d837eaf15d00e05c80fe;
    //     wrappedProxy1.joinLottery(data);
    //     vm.stopPrank();
    // }
}
