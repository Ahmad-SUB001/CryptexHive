// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title CryptexHive
 * @dev A decentralized vault system where users can deposit and withdraw Ether securely.
 *      The contract maintains individual balances and allows the owner to view total deposits.
 */
contract CryptexHive {
    address public owner;
    mapping(address => uint256) private userBalances;
    uint256 private totalVaultBalance;

    // Events
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    /**
     * @notice Deposit Ether into the vault.
     */
    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        userBalances[msg.sender] += msg.value;
        totalVaultBalance += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    /**
     * @notice Withdraw specified Ether amount from your vault balance.
     * @param amount The amount to withdraw.
     */
    function withdraw(uint256 amount) external {
        require(userBalances[msg.sender] >= amount, "Insufficient balance");
        userBalances[msg.sender] -= amount;
        totalVaultBalance -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @notice View your vault balance.
     * @return balance User's vault balance.
     */
    function getMyBalance() external view returns (uint256) {
        return userBalances[msg.sender];
    }

    /**
     * @notice View total vault balance (owner only).
     * @return totalVaultBalance Total Ether in the vault.
     */
    function getTotalVaultBalance() external view returns (uint256) {
        require(msg.sender == owner, "Only owner can view total balance");
        return totalVaultBalance;
    }
}

