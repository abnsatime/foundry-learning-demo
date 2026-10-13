// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {LearningToken} from "../src/LearningToken.sol";

contract LearningTokenTest is Test {
    uint256 internal constant INITIAL_SUPPLY = 1_000_000 * 10 ** 18;

    LearningToken internal token;

    function setUp() public {
        token = new LearningToken(INITIAL_SUPPLY);
    }

    function test_Metadata() public view {
        assertEq(token.name(), "Learning Token");
        assertEq(token.symbol(), "LRN");
        assertEq(token.decimals(), 18);
    }

    function test_InitialSupplyAssignedToDeployer() public view {
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.balanceOf(address(this)), INITIAL_SUPPLY);
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    function test_ConstructorEmitsMintTransfer() public {
        vm.expectEmit(true, true, false, true);

        emit Transfer(address(0), address(this), INITIAL_SUPPLY);

        new LearningToken(INITIAL_SUPPLY);
    }
}
