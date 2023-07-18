//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "@openzeppelin-upgrade/contracts/utils/math/SafeMathUpgradeable.sol";

library SelectLibrary {
    using SafeMathUpgradeable for uint256;

    struct Depositor {
        address user;
        uint256 amount;
    }

    function quickselect(
        Depositor[] storage arr,
        bytes32 rootHash,
        uint256 left,
        uint256 right,
        uint256 k,
        address[] memory winners
    ) public returns (bool) {
        if (left == right) {
            return true;
        }

        uint256 pivotIndex = randomizedPartition(arr, rootHash, left, right);
        uint256 pivotRank = pivotIndex - left + 1;

        if (k == pivotRank) {
            for (uint256 i = 0; i < k; i++) {
                winners[i] = arr[left + i].user;
            }
        } else if (k < pivotRank) {
            return quickselect(arr, rootHash, left, pivotIndex - 1, k, winners);
        } else {
            for (uint256 i = 0; i < pivotRank; i++) {
                winners[i] = arr[left + i].user;
            }

            return
                quickselect(
                    arr,
                    rootHash,
                    pivotIndex + 1,
                    right,
                    k - pivotRank,
                    winners
                );
        }

        return false;
    }

    function randomizedPartition(
        Depositor[] storage arr,
        bytes32 rootHash,
        uint256 left,
        uint256 right
    ) private returns (uint256) {
        uint256 pivotIndex = randomInRange(rootHash, left, right);
        swap(arr, right, pivotIndex);

        return partition(arr, left, right);
    }

    function partition(
        Depositor[] storage arr,
        uint256 left,
        uint256 right
    ) private returns (uint256) {
        uint256 pivot = arr[right].amount;
        uint256 i = left;

        for (uint256 j = left; j < right; j++) {
            if (arr[j].amount >= pivot) {
                swap(arr, i, j);
                i++;
            }
        }

        swap(arr, i, right);

        return i;
    }

    function swap(Depositor[] storage arr, uint256 i, uint256 j) private {
        Depositor memory temp = arr[i];
        arr[i] = arr[j];
        arr[j] = temp;
    }

    function randomInRange(
        bytes32 rootHash,
        uint256 min,
        uint256 max
    ) private view returns (uint256) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                rootHash,
                block.timestamp,
                block.difficulty,
                block.coinbase
            )
        );

        uint256 randomNumber = uint256(hash);

        return randomNumber.mod(max - min + 1).add(min);
    }
}
