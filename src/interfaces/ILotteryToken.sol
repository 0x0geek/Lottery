//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface ILotteryToken {
    function mintToken(address _to) external returns (uint256);

    function tokenIdOf(address _to) external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address);

    function changeManagerAddress(address _address) external;
}
