// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "@openzeppelin-upgrade/contracts/proxy/ClonesUpgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "../src/LotteryV1.sol";
import "../src/LotteryV2.sol";
import "../src/LotteryToken.sol";
import "../src/WrappedLotteryToken.sol";
import "../src/VRFConsumer.sol";

import "./utils/Math.sol";
import {BaseSetup} from "./BaseSetup.sol";
import {UUPSProxy} from "./utils/UUPSProxy.sol";

contract LotteryTest is BaseSetup {
    using ClonesUpgradeable for address;
    using MathCeil for uint256;

    LotteryToken public token;
    WrappedLotteryToken public wrappedToken;

    LotteryV1 public lottery1;
    LotteryV2 public lottery2;
    VRFConsumer public vrfConsumer;

    LotteryV1 public wrappedProxy1;
    LotteryV2 public wrappedProxy2;

    UUPSProxy public proxy;

    uint8 internal constant PROTOCOL_FEE = 10;
    uint8 internal constant RENTTOKEN_FEE = 80;
    uint32 internal constant WINNER_COUNT = 10;
    uint64 internal constant SUBSCRIPTION_ID = 5534;
    uint256 internal constant RENT_AMOUNT = 3;

    bytes32 internal constant ROOT_HASH =
        0x3f00740cab856a945742c57efce40128df32394d0d7e8732fe46a36da2e40d1a;

    function setUp() public virtual override {
        BaseSetup.setUp();

        token = new LotteryToken("Nft token", "NFT_TOKEN");
        wrappedToken = new WrappedLotteryToken(
            "Wrapped Nft token",
            "WRAPPED_NFT_TOKEN"
        );

        vrfConsumer = new VRFConsumer(WINNER_COUNT, SUBSCRIPTION_ID);

        lottery1 = new LotteryV1();
        proxy = new UUPSProxy(address(lottery1), "");

        wrappedProxy1 = LotteryV1(address(proxy));

        wrappedProxy1.initialize(
            PROTOCOL_FEE,
            RENTTOKEN_FEE,
            WINNER_COUNT,
            RENT_AMOUNT,
            address(david),
            address(token),
            address(wrappedToken),
            address(vrfConsumer)
        );

        token.changeManagerAddress(address(wrappedProxy1));
        wrappedToken.changeManagerAddress(address(wrappedProxy1));
        vrfConsumer.setLotteryAddress(address(wrappedProxy1));
        vrfConsumer.changeOwnerAddress(address(wrappedProxy1));
    }

    function testCanInitialize() public {
        assertEq(wrappedProxy1.rentAmount(), RENT_AMOUNT);
        assertEq(wrappedProxy1.rentTokenFee(), RENTTOKEN_FEE);
        assertEq(wrappedProxy1.protocolFee(), PROTOCOL_FEE);
        assertEq(wrappedProxy1.numberOfWinners(), WINNER_COUNT);
    }

    function testCanUpgrade() public {
        // Create Lottery V2 contract for upgrade.
        lottery2 = new LotteryV2();
        wrappedProxy1.upgradeTo(address(lottery2));

        // re-wrap the proxy
        wrappedProxy2 = LotteryV2(address(proxy));

        // Once upgrade is finished, check Lottery V1's variable is still alive
        assertEq(wrappedProxy2.rentAmount(), RENT_AMOUNT);

        // Once upgrade is finished, check if the new function is working fine.
        wrappedProxy2.setPrizeAmount(200);
        assertEq(wrappedProxy2.prizeAmount(), 200);
        assertEq(wrappedProxy2.rentAmount(), RENT_AMOUNT);
        assertEq(wrappedProxy2.rentTokenFee(), RENTTOKEN_FEE);
        assertEq(wrappedProxy2.protocolFee(), PROTOCOL_FEE);
        assertEq(wrappedProxy2.numberOfWinners(), WINNER_COUNT);
    }

    function testStartLottery() public {
        // Alice is not onwer and tries to start lottery, should revert
        vm.startPrank(alice);
        vm.expectRevert("Ownable: caller is not the owner");
        wrappedProxy1.startLottery(ROOT_HASH);
        vm.stopPrank();

        // Onwer tries to start lottery with invalid root hash address
        vm.expectRevert(LotteryV1.NotValidRootHash.selector);
        wrappedProxy1.startLottery(bytes32(0));

        wrappedProxy1.startLottery(ROOT_HASH);
    }

    function testDecideWinner() public {
        // Alice is not onwer and tries to start lottery, should revert
        vm.startPrank(alice);
        vm.expectRevert("Ownable: caller is not the owner");
        wrappedProxy1.decideWinner();
        vm.stopPrank();

        // Onwer tries to decide winner, but lottery is not started yet, should revert
        vm.expectRevert(LotteryV1.LotteryNotInDepositPeriod.selector);
        wrappedProxy1.decideWinner();

        // Onwer sets number of winner
        wrappedProxy1.setNumberOfWinners(WINNER_COUNT);

        // Onwer start lottery
        wrappedProxy1.startLottery(ROOT_HASH);

        // Onwer tries to decide winner, but no participants in the lottery, should revert
        vm.expectRevert(LotteryV1.NoParticipantsInLottery.selector);
        wrappedProxy1.decideWinner();

        bytes32[] memory proof = new bytes32[](0);

        // Alice participate in the current lottery with 20 Ether
        vm.prank(alice);
        wrappedProxy1.joinLottery{value: 20 ether}(proof);

        // Bob participate in the current lottery with 10 Ether
        vm.prank(bob);
        wrappedProxy1.joinLottery{value: 10 ether}(proof);

        // Owner sets number of winner 10, but the number of participator is 2 now, should revert
        vm.expectRevert(LotteryV1.InvalidNumberOfWinners.selector);
        wrappedProxy1.decideWinner();

        // Frag joins to lottery and he is a whitelist user, so that he doesn't send Ether.
        vm.prank(fraig);
        wrappedProxy1.joinLottery(getFraigProof());

        uint256 depositAmount;

        // N members participate in the current lottery
        for (uint256 i = 5; i != users.length; ++i) {
            uint256 randomNumber = getRandom();
            depositAmount = randomNumber % (1 * ETHER_DECIMAL);
            vm.prank(users[i]);
            wrappedProxy1.joinLottery{value: depositAmount}(proof);

            skip(3600);
        }

        wrappedProxy1.decideWinner();
    }

    function testClaimReward() public {
        vm.startPrank(alice);
        // Alice tries to enter the current lottery, but lottery is not started yet, therfore should revert
        vm.expectRevert(LotteryV1.NotSelectedWinners.selector);
        wrappedProxy1.claimReward();
        vm.stopPrank();

        initLotteryConf();

        // Bob borrows alice's NFT ticket
        vm.prank(bob);
        wrappedProxy1.rentTicket{value: RENT_AMOUNT}(address(alice));

        // Owner decided winner
        wrappedProxy1.decideWinner();

        uint256 balanceBefore = address(bob).balance;

        // Bob claims reward
        vm.prank(bob);
        wrappedProxy1.claimReward();

        uint256 bobReward = address(bob).balance - balanceBefore;

        // Bob's lender is Alice and He claims reward
        balanceBefore = address(alice).balance;
        vm.prank(alice);
        wrappedProxy1.claimReward();

        uint256 aliceReward = address(alice).balance - balanceBefore;

        uint256 totalReward = aliceReward + bobReward;

        // check if Bobs claimed 20% NFT ticket's reward and Alice claimed 80% of it.
        assertEq(bobReward, (totalReward * 20) / 100);
        assertEq(aliceReward, (totalReward * 80).divCeil(100));

        /// warning claim test in not break period
    }

    function testJoinLottery() public {
        bytes32[] memory proof = new bytes32[](0);

        // Alice tries to enter the current lottery, but lottery is not started yet, therfore should revert
        vm.startPrank(alice);
        vm.expectRevert(LotteryV1.LotteryNotInDepositPeriod.selector);
        wrappedProxy1.joinLottery{value: 10}(proof);
        vm.stopPrank();

        // Onwer set number of winners as 2
        wrappedProxy1.setNumberOfWinners(2);

        // Owner start the new  lottery
        wrappedProxy1.startLottery(ROOT_HASH);

        // Alice is not a whitelist user,but tries to participate in the lottery without deposited amount and proof.
        vm.startPrank(alice);
        vm.expectRevert(LotteryV1.NotWhitelistedUser.selector);
        wrappedProxy1.joinLottery(proof);

        // Alice participate in the current lottery
        wrappedProxy1.joinLottery{value: 10}(proof);

        skip(1000);

        // Alice deposit amount in the current lottery again
        wrappedProxy1.joinLottery{value: 20}(proof);
        vm.stopPrank();

        // Bob participate in the current lottery again
        vm.prank(bob);
        wrappedProxy1.joinLottery{value: 30}(proof);

        // Carol participate in the current lottery again
        vm.prank(carol);
        wrappedProxy1.joinLottery{value: 15}(proof);

        // Carol participate in the current lottery again
        vm.prank(edward);
        wrappedProxy1.joinLottery{value: 5}(proof);

        // Owner decides winner
        wrappedProxy1.decideWinner();

        // Carol tries to participate in the current lottery, but deposit amount is already ended, should revert
        vm.expectRevert(LotteryV1.LotteryNotInDepositPeriod.selector);
        vm.prank(carol);
        wrappedProxy1.joinLottery{value: 10}(proof);
    }

    function testRentTicket() public {
        bytes32[] memory proof = new bytes32[](0);

        // Alice tries to enter the current lottery, but lottery is not started yet, therfore should revert
        vm.startPrank(alice);
        vm.expectRevert(LotteryV1.LotteryNotInDepositPeriod.selector);
        wrappedProxy1.rentTicket{value: 10}(address(alice));
        vm.stopPrank();

        // Owner start the new  lottery
        wrappedProxy1.startLottery(ROOT_HASH);

        // Alice participate in the current lottery
        vm.startPrank(alice);
        wrappedProxy1.joinLottery{value: 10}(proof);

        // Alice tries to borrow NFT ticket with 2 Ether, but rent amount is 3, should revert
        vm.expectRevert(LotteryV1.InsufficientRentAmount.selector);
        wrappedProxy1.rentTicket{value: 2}(address(alice));

        // Alice tries to borrow his NFT ticket with 3 Ether, but can't borrow his own ticket, should revert
        vm.expectRevert(LotteryV1.NotRentableForOwner.selector);
        wrappedProxy1.rentTicket{value: RENT_AMOUNT}(address(alice));
        vm.stopPrank();

        vm.startPrank(bob);
        // Bob borrows carol's NFT ticket with 3 Ether, but Carol hasn't a NFT ticket for him, so should revert
        vm.expectRevert(LotteryV1.InvalidTicketForOwner.selector);
        wrappedProxy1.rentTicket{value: RENT_AMOUNT}(address(carol));

        // Bob borrows alice's NFT ticket
        wrappedProxy1.rentTicket{value: RENT_AMOUNT}(address(alice));
        vm.stopPrank();
    }

    function testWithdrawProtocolReward() public {
        initLotteryConf();

        // Owner decides lottery's winner.
        wrappedProxy1.decideWinner();

        // Alice tries to withdraw the protocol reward and he is not a developer of contract, should revert
        vm.expectRevert(LotteryV1.InvalidDevAddress.selector);
        vm.prank(alice);
        wrappedProxy1.withdrawProtocolReward();

        uint256 balanceBefore = address(david).balance;

        // David is a developer, possible to withdraw protocol reward
        vm.prank(david);
        wrappedProxy1.withdrawProtocolReward();

        assertGe(address(david).balance, balanceBefore);
    }

    function testWithdrawProtocolRewardWithAmount() public {
        initLotteryConf();

        // Owner decides lottery's winner.
        wrappedProxy1.decideWinner();

        // Alice tries to withdraw the protocol reward and he is not a developer of contract, should revert
        vm.expectRevert(LotteryV1.InvalidDevAddress.selector);
        vm.prank(alice);
        wrappedProxy1.withdrawProtocolReward(10 ether);

        uint256 balanceBefore = address(david).balance;

        // David is a developer, possible to withdraw protocol reward
        vm.prank(david);
        wrappedProxy1.withdrawProtocolReward(10 ether);

        assertEq(address(david).balance, balanceBefore + 10 ether);
    }

    function testSetRentTokenFee() public {
        // Alice tries to set rent token fee, but he is not a owner, should rever
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(alice);
        wrappedProxy1.setRentTokenFee(RENTTOKEN_FEE);

        // Lottery is already started, hence should revert
        wrappedProxy1.setRentTokenFee(RENTTOKEN_FEE);

        // Owner starts new lottery.
        wrappedProxy1.startLottery(ROOT_HASH);

        // Lottery is already started, hence should revert
        vm.expectRevert(LotteryV1.LotteryNotEnded.selector);
        wrappedProxy1.setRentTokenFee(RENTTOKEN_FEE);
    }

    function initLotteryConf() private {
        bytes32[] memory aliceProof = new bytes32[](0);

        // Owner starts new lottery.
        wrappedProxy1.startLottery(ROOT_HASH);

        // Alice joins to lottery with 10 Ether.
        vm.prank(alice);
        wrappedProxy1.joinLottery{value: 10 ether}(aliceProof);

        // Carol joins to lottery and he is a whitelist user, so that he doesn't send Ether.
        vm.prank(carol);
        wrappedProxy1.joinLottery(getCarolProof());

        // Alice deposit 20 Ether again
        vm.prank(alice);
        wrappedProxy1.joinLottery{value: 20 ether}(aliceProof);

        // Frag joins to lottery and he is a whitelist user, so that he doesn't send Ether.
        vm.prank(fraig);
        wrappedProxy1.joinLottery(getFraigProof());

        uint256 depositAmount;

        for (uint256 i = 10; i != users.length; ++i) {
            uint256 randomNumber = getRandom();
            depositAmount = randomNumber % (1 * ETHER_DECIMAL);
            vm.prank(users[i]);
            wrappedProxy1.joinLottery{value: depositAmount}(aliceProof);

            skip(360);
        }
    }

    function testIntegration() public {
        initLotteryConf();

        // Owner decides lottery's winner.
        wrappedProxy1.decideWinner();

        // Alice claims his reward
        vm.prank(alice);
        wrappedProxy1.claimReward();
    }

    function getRandom() private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        ROOT_HASH,
                        block.timestamp,
                        block.difficulty
                    )
                )
            );
    }
}
