//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface ILotteryV1 {
    function fulfillRandomWords(uint[] memory) external;
}
