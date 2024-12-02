// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/BlumeLiquidStaking.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor() ERC20("MockToken", "MKT") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract BlumeLiquidStakingTest is Test {
    BlumeLiquidStaking public stakingContract;
    MockToken public BLS;
    MockToken public stBLS;

    address public user = address(0x123);

    function setUp() public {
        // Deploy mock tokens
        BLS = new MockToken();
        stBLS = new MockToken();

        // Deploy the staking contract
        stakingContract = new BlumeLiquidStaking(address(BLS), address(stBLS));

        // Mint tokens for user
        BLS.mint(user, 1000 ether);
        stBLS.mint(address(stakingContract), 1000 ether);

        // Approve staking contract to spend BLS tokens of user.
        vm.prank(user);
        BLS.approve(address(stakingContract), type(uint256).max);
    }

    function testStake() public {
        vm.prank(user);
        stakingContract.stake(100 ether);

        // Assert balances
        assertEq(BLS.balanceOf(user), 900 ether);
        assertEq(stBLS.balanceOf(user), 100 ether);
    }

    function testUnstake() public {
    uint256 initialBalance = BLS.balanceOf(user); // Save the initial balance
    uint256 stakeAmount = 100 ether;

    // Stake tokens
    vm.prank(user);
    stakingContract.stake(stakeAmount);

    // Approve the tranfer of tokens
    vm.prank(user);
    stBLS.approve(address(stakingContract), stakeAmount);

    // Unstake tokens
    vm.prank(user);
    stakingContract.unstake(stakeAmount);

    // Assertions
    assertEq(BLS.balanceOf(user), initialBalance, "User should receive their original balance back");
    assertEq(stBLS.balanceOf(user), 0, "User's staked tokens should be burned");
    }


    function testFail_Unstake_Without_Staking() public {
        vm.prank(user);
        stakingContract.unstake(100 ether); // Should fail
    }
}
