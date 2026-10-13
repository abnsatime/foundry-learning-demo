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

    uint256 internal constant TRANSFER_AMOUNT = 100 * 10 ** 18;

    address internal bob = makeAddr("bob");

    function test_TransferMovesTokens() public {
        uint256 senderBalanceBefore = token.balanceOf(address(this));
        uint256 receiverBalanceBefore = token.balanceOf(bob);

        bool success = token.transfer(bob, TRANSFER_AMOUNT);

        assertTrue(success);

        assertEq(token.balanceOf(bob), receiverBalanceBefore + TRANSFER_AMOUNT);

        assertEq(token.balanceOf(address(this)), senderBalanceBefore - TRANSFER_AMOUNT);

        assertEq(token.totalSupply(), INITIAL_SUPPLY);
    }

    function test_RevertWhenReceiverIsZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(LearningToken.ERC20InvalidReceiver.selector, address(0)));

        token.transfer(address(0), TRANSFER_AMOUNT);
    }

    function test_RevertWhenSenderBalanceIsInsufficient() public {
        uint256 excessiveAmount = INITIAL_SUPPLY + 1;

        vm.expectRevert(
            abi.encodeWithSelector(
                LearningToken.ERC20InsufficientBalance.selector, address(this), INITIAL_SUPPLY, excessiveAmount
            )
        );

        token.transfer(bob, excessiveAmount);
    }

    function test_TransferEmitsEvent() public {
        vm.expectEmit(true, true, false, true);

        emit Transfer(address(this), bob, TRANSFER_AMOUNT);

        token.transfer(bob, TRANSFER_AMOUNT);
    }

    function test_TransferZeroAmountSucceeds() public {
        uint256 senderBalanceBefore = token.balanceOf(address(this));
        uint256 receiverBalanceBefore = token.balanceOf(bob);

        vm.expectEmit(true, true, false, true);
        emit Transfer(address(this), bob, 0);

        bool success = token.transfer(bob, 0);

        assertTrue(success);
        assertEq(token.balanceOf(address(this)), senderBalanceBefore);

        assertEq(token.balanceOf(bob), receiverBalanceBefore);
    }

    function test_TransferToSelfKeepBalance() public {
        uint256 balanceBefore = token.balanceOf(address(this));

        bool success = token.transfer(address(this), TRANSFER_AMOUNT);

        assertTrue(success);
        assertEq(token.balanceOf(address(this)), balanceBefore);

        assertEq(token.totalSupply(), INITIAL_SUPPLY);
    }
}
