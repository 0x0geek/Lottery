//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IWrappedLotteryToken {
    function mintToken(address _owner, address _to) external returns (uint256);

    function burnToken(address _to) external;

    function tokenIdOf(address _to) external view returns (uint256);

    function originOwnerOf(uint256 _tokenId) external view returns (address);

    function ownerOf(uint256 tokenId) external view returns (address);
}
