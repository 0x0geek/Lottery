// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./LotteryV1.sol";

contract LotteryV2 is LotteryV1 {
    uint256 public prizeAmount;

    function setPrizeAmount(uint256 _prizeAmount) public {
        prizeAmount = _prizeAmount;
    }
}
