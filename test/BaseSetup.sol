// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {console} from "forge-std/console.sol";
import {stdStorage, StdStorage, Test} from "forge-std/Test.sol";

import {Utils} from "./utils/Util.sol";

contract BaseSetup is Test {
    // Skip forward block.timestamp for 3 days.
    uint256 internal constant SKIP_FORWARD_PERIOD = 3600 * 24 * 3;
    uint256 internal constant USDC_DECIMAL = 1e6;
    uint256 internal constant ETHER_DECIMAL = 1e18;

    Utils internal utils;

    address payable[] internal users;
    address internal alice;
    address internal bob;
    address internal carol;
    address internal david;
    address internal edward;
    address internal fraig;

    function setUp() public virtual {
        utils = new Utils();
        users = utils.createUsers(50);

        alice = users[0];
        vm.label(alice, "Alice");

        bob = users[1];
        vm.label(bob, "Bob");

        carol = users[2];
        vm.label(carol, "Carol");

        david = users[3];
        vm.label(david, "David");

        edward = users[4];
        vm.label(edward, "Edward");

        fraig = users[5];
        vm.label(fraig, "Fraig");
    }
}
