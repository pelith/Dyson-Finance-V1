// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;


import "../DYSON.sol";
import "../sDYSON.sol";
import "./Addresses.sol";
import "./Amounts.sol";
import "forge-std/Test.sol";
import "src/util/sDYSONAirdrop.sol";

contract sDYSONAirdropDeployScript is Addresses, Amounts, Test {
    DYSON public dyson = DYSON(getAddress("DYSON"));
    sDYSON public sDyson = sDYSON(getAddress("sDYSON"));
    sDYSONAirdrop public airdrop;

    uint claimStartTime = 1701162600; // ??
    uint claimEndTime = claimStartTime + 7 days; // ??
    bytes32 merkleRoot = 0xc972b65d8f6b48484ebd88dc5c589e13c3169aee4e525c14952f6fc92e4c899a; // ??

    function run() external {
        address owner = vm.envAddress("OWNER_ADDRESS");
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        airdrop = new sDYSONAirdrop(owner, address(dyson), address(sDyson), merkleRoot, claimStartTime, claimEndTime);
        console.log("%s", "done");
        console.log("{");
        console.log("\"sDYSONAirdrop\": \"%s\",", address(airdrop));
        console.log("}");
        vm.stopBroadcast();
    }

}