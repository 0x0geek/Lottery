//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./LotteryToken.sol";

contract WrappedLotteryToken is LotteryToken {
    mapping(uint256 => address) internal originTokenOwners; // wrapped Token Id and NFT ticket owner

    constructor(
        address _address,
        string memory _name,
        string memory _symbol
    ) LotteryToken(_address, _name, _symbol) {}

    function mintToken(
        address _owner,
        address _to
    ) external onlyManager returns (uint256) {
        uint256 newTokenId = super._mintToken(_to);

        originTokenOwners[newTokenId] = _owner;

        return newTokenId;
    }

    function burnToken(address _to) external onlyManager {
        uint256 tokenId = tokenIds[_to];

        delete originTokenOwners[tokenId];

        _burn(tokenId);
    }

    function originOwnerOf(uint256 _tokenId) external view returns (address) {
        return originTokenOwners[_tokenId];
    }
}
