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

    function getCarolProof() internal pure virtual returns (bytes32[] memory) {
        bytes32[] memory carolProof = new bytes32[](6);
        carolProof[
            0
        ] = 0x411e41cf526f9b4828f6f061c006384b3f94d8fce89a584920eea74822442900;
        carolProof[
            1
        ] = 0x28ada27893d936924fa9e8cfebced2bf6e7a798d7ac2e83bcccf21529736d043;
        carolProof[
            2
        ] = 0x9a2e42a5ebbb8ba90ea2dccb4a5b0760b70531b2b96b04398a80e777cc714cab;
        carolProof[
            3
        ] = 0x060fc39ac014e73e7231eaa79053ef49eec49e3a554d1f68aa0f384cdfcb5599;
        carolProof[
            4
        ] = 0x568e566600331f0f34d18cb63c8d22c4878d32d5dedcc12330980f0b98742cdc;
        carolProof[
            5
        ] = 0x09ec4188996816741bb7669dc0236b4364c2aa3f50e355553036883b1e33615f;

        return carolProof;
    }

    function getFraigProof() internal pure virtual returns (bytes32[] memory) {
        bytes32[] memory fraigProof = new bytes32[](6);
        fraigProof[
            0
        ] = 0x5c5566ed9ca278962336d8318093681848d3b15d943f9984481273cd7a0bcdfe;
        fraigProof[
            1
        ] = 0x08e9d837d1874b31c14ba278d75a503e6e5a31653e74203255973ff6a0957581;
        fraigProof[
            2
        ] = 0x9fd6d6c685b39b8973429ce39ea7d8499ce3d7c1113b27a87d6bf18ff217e0fe;
        fraigProof[
            3
        ] = 0x060fc39ac014e73e7231eaa79053ef49eec49e3a554d1f68aa0f384cdfcb5599;
        fraigProof[
            4
        ] = 0x568e566600331f0f34d18cb63c8d22c4878d32d5dedcc12330980f0b98742cdc;
        fraigProof[
            5
        ] = 0x09ec4188996816741bb7669dc0236b4364c2aa3f50e355553036883b1e33615f;

        return fraigProof;
    }
}
