// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "./interfaces/ILotteryV1.sol";

contract VRFConsumer is VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface internal immutable COORDINATOR;
    ILotteryV1 internal immutable lottery;
    address internal constant VRF_COORDINATOR_ADDRESS =
        0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed;
    bytes32 internal constant KEY_HASH =
        0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;

    uint64 internal subscriptionId;

    //Mumbai has a max gas limit of 2.5 million,
    uint32 callbackGasLimit = 2500000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 5;
    uint32 public numWords = 10;
    uint256[] public randomWords;
    uint256 public requestId;
    address internal ownerAddress;

    modifier onlyOwner() {
        require(msg.sender == ownerAddress);
        _;
    }

    constructor(
        uint64 _subscriptionId,
        address _parentAddress
    ) VRFConsumerBaseV2(VRF_COORDINATOR_ADDRESS) {
        lottery = ILotteryV1(_parentAddress);
        COORDINATOR = VRFCoordinatorV2Interface(VRF_COORDINATOR_ADDRESS);
        ownerAddress = msg.sender;
        subscriptionId = _subscriptionId;
    }

    // Assumes the subscription is funded sufficiently.
    function requestRandomWords() external onlyOwner {
        // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            KEY_HASH,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    //function to change the number of requested words per VRF request.
    function setNumWords(uint32 _numWords) external onlyOwner {
        numWords = _numWords;
    }

    function fulfillRandomWords(
        uint256 /*_requestId*/,
        uint256[] memory _randomWords
    ) internal override {
        randomWords = _randomWords;
        lottery.fulfillRandomWords(_randomWords);
    }
}
