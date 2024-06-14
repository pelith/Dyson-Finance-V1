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

    uint claimStartTime = 1718529000; // "6/16 2024 17:10:00 GMT+0800"
    uint claimEndTime = claimStartTime + 3 days; // "6/19 2024 17:10:00 GMT+0800"
    bytes32 merkleRoot = 0x9a341a7efc5d188e2b148c4d71386d7767f32d2d69827ae3ed518db8d3e8af93; // zkevm s2-2

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