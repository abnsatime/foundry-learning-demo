// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Learning Token
/// @notice An educational token built step by step;
contract LearningToken {
    string public constant name = "Learning Token";
    string public constant symbol = "LRN";
    uint8 public constant decimals = 18;

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    error ERC20InvalidReceiver(address receiver);

    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @notice Creates the initial supply and assigns it to the deployer.
    /// @param initialSupply Amount expressed in the token's smallest unit.
    constructor(uint256 initialSupply) {
        totalSupply = initialSupply;
        balanceOf[msg.sender] = initialSupply;

        emit Transfer(address(0), msg.sender, initialSupply);
    }

    /// @notice Transfers tokens from the caller to another address.
    /// @param to Address receiving the tokens.
    /// @param amount Amount expressed in the token's smallest unit.
    /// @return success Always true when the transfer succeeds.
    function transfer(address to, uint256 amount) external returns (bool success) {
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }

        uint256 senderBalance = balanceOf[msg.sender];

        if (senderBalance < amount) {
            revert ERC20InsufficientBalance(msg.sender, senderBalance, amount);
        }

        balanceOf[msg.sender] = senderBalance - amount;
        balanceOf[to] += amount;

        emit Transfer(msg.sender, to, amount);

        return true;
    }
}

