// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {LearningToken} from "../src/LearningToken.sol";

contract LearningTokenTest is Test {
    uint256 internal constant INITIAL_SUPPLY = 1_000_000 * 10 ** 18;

    LearningToken internal token;

    address internal attacker = makeAddr("attacker");

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

    address internal spender = makeAddr("spender");

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function test_AllowanceDefaultsToZero() public view {
        assertEq(token.allowance(address(this), spender), 0);
    }

    function test_ApproveSetAllowanceAndReturnsTrue() public {
        bool success = token.approve(spender, TRANSFER_AMOUNT);

        assertTrue(success);

        assertEq(token.allowance(address(this), spender), TRANSFER_AMOUNT);
    }

    function test_ApproveEmitsEvent() public {
        vm.expectEmit(true, true, false, true);

        emit Approval(address(this), spender, TRANSFER_AMOUNT);

        token.approve(spender, TRANSFER_AMOUNT);
    }

    function test_ApproveOverwritesExistingAllowance() public {
        token.approve(spender, 50 * 10 ** 18);
        token.approve(spender, TRANSFER_AMOUNT);

        assertEq(token.allowance(address(this), spender), TRANSFER_AMOUNT);
    }

    function test_RevertWhenSpenderIsZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(LearningToken.ERC20InvalidSpender.selector, address(0)));

        token.approve(address(0), TRANSFER_AMOUNT);
    }

    function test_TransferFromMovesTokensAndSpendsAllowance() public {
        token.approve(spender, TRANSFER_AMOUNT);

        uint256 ownerBalanceBefore = token.balanceOf(address(this));
        uint256 receiverBalanceBefore = token.balanceOf(bob);

        vm.prank(spender);

        bool success = token.transferFrom(address(this), bob, TRANSFER_AMOUNT);
        assertTrue(success);

        assertEq(token.balanceOf(address(this)), ownerBalanceBefore - TRANSFER_AMOUNT);
        assertEq(token.balanceOf(bob), receiverBalanceBefore + TRANSFER_AMOUNT);
        assertEq(token.allowance(address(this), spender), 0);

        assertEq(token.totalSupply(), INITIAL_SUPPLY);
    }

    function test_RevertWhenTransferFromAllowanceIsInsufficient() public {
        uint256 approvedAmount = 50 * 10 ** 18;
        token.approve(spender, approvedAmount);

        vm.prank(spender);
        vm.expectRevert(
            abi.encodeWithSelector(
                LearningToken.ERC20InsufficientAllowance.selector, spender, approvedAmount, TRANSFER_AMOUNT
            )
        );

        token.transferFrom(address(this), bob, TRANSFER_AMOUNT);
    }

    function test_RevertWhenTransferFromOwnerBalanceIsInsufficient() public {
        uint256 excessiveAmount = INITIAL_SUPPLY + 1;

        token.approve(spender, excessiveAmount);

        vm.prank(spender);
        vm.expectRevert(
            abi.encodeWithSelector(
                LearningToken.ERC20InsufficientBalance.selector, address(this), INITIAL_SUPPLY, excessiveAmount
            )
        );

        token.transferFrom(address(this), bob, excessiveAmount);

        assertEq(token.allowance(address(this), spender), excessiveAmount);
    }

    function test_RevertWhenTransferFromReceiverIsZeroAddress() public {
        token.approve(spender, TRANSFER_AMOUNT);

        vm.prank(spender);
        vm.expectRevert(abi.encodeWithSelector(LearningToken.ERC20InvalidReceiver.selector, address(0)));

        token.transferFrom(address(this), address(0), TRANSFER_AMOUNT);

        assertEq(token.allowance(address(this), spender), TRANSFER_AMOUNT);
    }

    function test_TransferFromEmitsEvent() public {
        token.approve(spender, TRANSFER_AMOUNT);

        vm.expectEmit(true, true, false, true);

        emit Transfer(address(this), bob, TRANSFER_AMOUNT);

        vm.prank(spender);
        token.transferFrom(address(this), bob, TRANSFER_AMOUNT);
    }

    function test_AllowanceIsScopedToSpender() public {
        token.approve(spender, TRANSFER_AMOUNT);

        vm.prank(attacker);
        vm.expectRevert(
            abi.encodeWithSelector(LearningToken.ERC20InsufficientAllowance.selector, attacker, 0, TRANSFER_AMOUNT)
        );
        token.transferFrom(address(this), bob, TRANSFER_AMOUNT);

        assertEq(token.allowance(address(this), spender), TRANSFER_AMOUNT);
    }

    function test_TransferFromZeroAmountSucceeds() public {
        uint256 ownerBalanceBefore = token.balanceOf(address(this));
        uint256 receiverBalanceBefore = token.balanceOf(bob);

        vm.expectEmit(true, true, false, true);
        emit Transfer(address(this), bob, 0);

        vm.prank(spender);

        bool success = token.transferFrom(address(this), bob, 0);

        assertTrue(success);

        assertEq(token.balanceOf(address(this)), ownerBalanceBefore);
        assertEq(token.balanceOf(bob), receiverBalanceBefore);
        assertEq(token.allowance(address(this), spender), 0);
    }

    function test_RevertWhenTransferFromSenderIsZeroAddress() public {
        vm.prank(spender);
        vm.expectRevert(abi.encodeWithSelector(LearningToken.ERC20InvalidSender.selector, address(0)));

        token.transferFrom(address(0), bob, 0);
    }
}
