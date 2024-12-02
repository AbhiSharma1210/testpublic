// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/BlumeLiquidStaking.sol";
import "../test/BlumeLiquidStaking.t.sol"; // Import the mock tokens for testing

contract DeployBlumeLiquidStaking is Script {
    function run() external {
        vm.startBroadcast();

        MockToken blsToken = new MockToken();
        MockToken stBlsToken = new MockToken();

        BlumeLiquidStaking blumeStaking = new BlumeLiquidStaking(address(blsToken), address(stBlsToken));

        console.log("BLS Token Address:", address(blsToken));
        console.log("stBLS Token Address:", address(stBlsToken));
        console.log("BlumeLiquidStaking Contract Address:", address(blumeStaking));

        vm.stopBroadcast();
    }
}
