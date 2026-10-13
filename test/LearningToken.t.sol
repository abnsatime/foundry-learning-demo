// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {LearningToken} from "../src/LearningToken.sol";

contract LearningTokenTest is Test {
    LearningToken internal token;

    function setUp() public {
        token = new LearningToken();
    }

    function test_Metadata() public view {
        assertEq(token.name(), "Learning Token");
        assertEq(token.symbol(), "LRN");
        assertEq(token.decimals(), 18);
    }
}
