//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "forge-std/console.sol";

contract LotteryToken is ERC721 {
    using Counters for Counters.Counter;

    Counters.Counter private tokenIdCounter;

    mapping(address => uint256) public tokenIds;

    // address
    address internal managerAddress;

    error NotAvailableForUser();

    modifier onlyManager() {
        checkIsManager();
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        managerAddress = msg.sender;
    }

    function changeManagerAddress(address _manager) external onlyManager {
        managerAddress = _manager;
    }

    function mintToken(address _to) external onlyManager returns (uint256) {
        return _mintToken(_to);
    }

    function tokenIdOf(address _to) external view returns (uint256) {
        return tokenIds[_to];
    }

    function _mintToken(address _to) internal returns (uint256) {
        tokenIdCounter.increment();

        uint256 newTokenId = tokenIdCounter.current();
        _mint(_to, newTokenId);

        tokenIds[_to] = newTokenId;

        return newTokenId;
    }

    function checkIsManager() internal view virtual {
        if (managerAddress != _msgSender()) revert NotAvailableForUser();
    }
}
