// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {LearningToken} from "../src/LearningToken.sol";

contract DeployLearningToken is Script {
    uint256 internal constant INITIAL_SUPPLY = 1_000_000 * 10 ** 18;

    function run() external returns (LearningToken token) {
        vm.startBroadcast();

        token = new LearningToken(INITIAL_SUPPLY);

        vm.stopBroadcast();
    }
}
