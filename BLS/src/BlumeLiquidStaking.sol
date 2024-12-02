// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Blume Liquid Staking Contract
 * @dev Implements a staking mechanism with BLS and stBLS tokens.
 */
contract BlumeLiquidStaking is Ownable {
    ERC20 public BLS; // The BLS token
    ERC20 public stBLS; // The staked BLS (stBLS) token

    mapping(address => uint256) public stakedBalances; // Tracks staked BLS balances

    /**
     * @dev Initializes the staking contract with BLS and stBLS tokens.
     * @param _BLS Address of the BLS token contract.
     * @param _stBLS Address of the stBLS token contract.
     */
    constructor(address _BLS, address _stBLS) Ownable(msg.sender) {
        BLS = ERC20(_BLS);
        stBLS = ERC20(_stBLS);
    }

    /**
     * @dev Stake BLS tokens and mint stBLS tokens.
     * @param _amount The amount of BLS tokens to stake.
     */
    function stake(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than zero");

        // Transfer BLS tokens from the sender to the contract
        BLS.transferFrom(msg.sender, address(this), _amount);

        // Mint stBLS tokens to the sender
        stakedBalances[msg.sender] += _amount;
        stBLS.transfer(msg.sender, _amount); // Mint 1:1 stBLS

        emit Staked(msg.sender, _amount);
    }

    /**
     * @dev Unstake BLS tokens and burn stBLS tokens.
     * @param _amount The amount of stBLS tokens to unstake.
     */
    function unstake(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than zero");
        require(stakedBalances[msg.sender] >= _amount, "Insufficient staked balance");

        // Burn stBLS tokens from the sender
        stBLS.transferFrom(msg.sender, address(this), _amount);
        stakedBalances[msg.sender] -= _amount;

        // Transfer BLS tokens back to the sender
        BLS.transfer(msg.sender, _amount);

        emit Unstaked(msg.sender, _amount);
    }

    /**
     * @dev Withdraws all staked BLS tokens from the contract (admin only).
     */
    function withdrawAll() external onlyOwner {
        uint256 contractBalance = BLS.balanceOf(address(this));
        BLS.transfer(owner(), contractBalance);
    }

    /**
     * @dev Event emitted when a user stakes BLS tokens.
     */
    event Staked(address indexed user, uint256 amount);

    /**
     * @dev Event emitted when a user unstakes BLS tokens.
     */
    event Unstaked(address indexed user, uint256 amount);
}
