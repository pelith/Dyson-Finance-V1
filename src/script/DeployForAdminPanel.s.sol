// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../AdminPanel.sol";
import "forge-std/Script.sol";

contract AdminPanelDeployScript is Script{

    AdminPanel adminPanel;

    // forge script src/script/DeployForAdminPanel.s.sol:AdminPanelDeployScript --rpc-url {SEPOLIA_URL} --broadcast --use 0.8.17 --optimizer-runs 200 --legacy  --verify
    function run() external {
        address owner = vm.envAddress("OWNER_ADDRESS");
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        adminPanel = new AdminPanel();
        adminPanel.transferOwnership(owner);

        vm.stopBroadcast();
    }
}