// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IVRFConsumer {
    // Assumes the subscription is funded sufficiently.
    function requestRandomWords() external;

    //function to change the number of requested words per VRF request.
    function setNumWords(uint32 _numWords) external;

    function setLotteryAddress(address _address) external;

    function changeOwnerAddress(address _owner) external;
}
