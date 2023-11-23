// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;


import "../DYSON.sol";
import "../sDYSON.sol";
import "../util/TreasuryVester.sol";
import "./Addresses.sol";
import "./Amounts.sol";
import "forge-std/Test.sol";

contract TreasuryVesterDeployScript is Addresses, Amounts, Test {
    DYSON public dyson = DYSON(getAddress("DYSON"));
    sDYSON public sDyson = sDYSON(getAddress("sDYSON"));
    
    // TreasuryVester configs
    uint public vestingBegin = block.timestamp + 31536000; // 1 year
    uint public vestingCliff = vestingBegin; // Same as vestingBegin
    uint public vestingEnd = vestingCliff + 31536000 * 2; // 2 years after vestingBegin

    address[] public treasuryVesters;

    function run() external {
        address owner = vm.envAddress("OWNER_ADDRESS");
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);
    
        // Deploy and setup TreasuryVesters
        address[] memory recipients = getAddresses("TreasuryRecipients");
        uint[] memory amounts = getAmounts("TreasuryAmounts");
        for(uint i = 0; i < recipients.length; ++i) {
            uint amount = amounts[i] * 1e18;
            TreasuryVester vester = new TreasuryVester(address(dyson), recipients[i], amount, vestingBegin, vestingCliff, vestingEnd);
            treasuryVesters.push(address(vester));
            dyson.mint(address(vester), amount);
        }

        // setup sDyson amounts
        recipients = getAddresses("sDYSONRecipients");
        amounts = getAmounts("sDYSONAmounts");
        uint totalMint;
        for(uint i = 0; i < amounts.length; ++i) {
            totalMint += amounts[i];
        }
        totalMint *= 1e18;
        dyson.mint(deployer, totalMint);
        dyson.approve(address(sDyson), type(uint).max);
        for(uint i = 0; i < recipients.length; ++i) {
            sDyson.stake(recipients[i], amounts[i]*1e18, 1461 days);  // locakDuration = 4 year (126144000 = 60*60*24*365*4)
        }

        // Mint Dyson for Ecosystem usage
        address daoWallet = vm.envAddress("DAO_WALLET");
        uint vestingAmount = 36000000e18; // 200M * 0.18
        vestingBegin = 1700640000; // 2023/11/22 16:00:00 (GMT+08:00)
        vestingCliff = vestingBegin; // Same as vestingBegin
        vestingEnd = vestingBegin + 1461 days;

        TreasuryVester ecosystemVester = new TreasuryVester(address(dyson), daoWallet, vestingAmount, vestingBegin, vestingCliff, vestingEnd);
        treasuryVesters.push(address(ecosystemVester));
        dyson.mint(address(ecosystemVester), vestingAmount);
        uint daoAmount = 4000000e18; // 200M * 0.02
        dyson.mint(daoWallet, daoAmount);

        // transfer ownership
        dyson.transferOwnership(owner);

        console.log("%s", "done");
        console.log("{");
        for (uint i = 0; i < treasuryVesters.length; ++i) {
            console.log("\"TreasuryVester%s\": \"%s\",", i, address(treasuryVesters[i]));
        }
        console.log("}");
        vm.stopBroadcast();
    }

}