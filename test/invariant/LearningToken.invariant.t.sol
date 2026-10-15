// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {StdInvariant} from "forge-std/StdInvariant.sol";
import {Test} from "forge-std/Test.sol";
import {LearningToken} from "../../src/LearningToken.sol";
import {LearningTokenHandler} from "./LearningTokenHandler.sol";

contract LearningTokenInvariantTest is StdInvariant, Test {
    uint256 internal constant INITIAL_SUPPLY = 1_000_000 * 10 ** 18;
    uint256 internal constant ACTOR_ALLOCATION = 100_000 * 10 ** 18;

    LearningToken internal token;
    LearningTokenHandler internal handler;

    address[] internal actors;

    function setUp() public {
        token = new LearningToken(INITIAL_SUPPLY);

        address[] memory actorList = new address[](3);
        actorList[0] = makeAddr("alice");
        actorList[1] = makeAddr("bob");
        actorList[2] = makeAddr("carol");

        for (uint256 i; i < actorList.length; ++i) {
            actors.push(actorList[i]);
            token.transfer(actorList[i], ACTOR_ALLOCATION);
        }

        handler = new LearningTokenHandler(token, actorList);

        targetContract(address(handler));
    }

    function invariant_TotalSupplyNeverChanges() public view {
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
    }

    function invariant_KnownBalancesEqualTotalSupply() public view {
        uint256 balanceSum = token.balanceOf(address(this));

        for (uint256 i; i < actors.length; ++i) {
            balanceSum += token.balanceOf(actors[i]);
        }

        assertEq(balanceSum, token.totalSupply());
    }
}
