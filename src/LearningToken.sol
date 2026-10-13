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

    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @notice Creates the initial supply and assigns it to the deployer.
    /// @param initialSupply Amount expressed in the token's smallest unit.
    constructor(uint256 initialSupply) {
        totalSupply = initialSupply;
        balanceOf[msg.sender] = initialSupply;

        emit Transfer(address(0), msg.sender, initialSupply);
    }
}

