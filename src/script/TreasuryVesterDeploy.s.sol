// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../Agency.sol";
import "../DYSON.sol";
import "../sDYSON.sol";
import "../Factory.sol";
import "../GaugeFactory.sol";
import "../BribeFactory.sol";
import "../Pair.sol";
import "../Router.sol";
import "../Farm.sol";
import "../Gauge.sol";
import "../Bribe.sol";
import "../util/AddressBook.sol";
import "../util/TokenSender.sol";
import "../util/TreasuryVester.sol";
import "../util/FeeDistributor.sol";
import "interface/IERC20.sol";
import "./Addresses.sol";
import "./Amounts.sol";
import "forge-std/Test.sol";

contract TreasuryVesterDeployScript is Addresses, Amounts, Test {
    // DYSON public dyson = DYSON(getAddress("DYSON"));
    // sDYSON public sDyson = sDYSON(getAddress("sDYSON"));
    
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

        DYSON dyson = new DYSON(deployer);
        sDYSON sDyson = new sDYSON(deployer, address(dyson));
        StakingRateModel model = new StakingRateModel(0.0625e18);
        sDyson.setStakingRateModel(address(model));
    

        // Deploy and setup TreasuryVesters, and stake to sDyson
        address[] memory recipients = getAddresses("TreasuryRecipients");
        uint[] memory amounts = getAmounts("TreasuryAmounts");
        for(uint i = 0; i < recipients.length; ++i) {
            uint amount = amounts[i];
            dyson.mint(deployer, amount);
            uint stakeAmount = amount / 8;
            uint vestingAmount = amount - stakeAmount;
            TreasuryVester vester = new TreasuryVester(address(dyson), recipients[i], vestingAmount, vestingBegin, vestingCliff, vestingEnd);
            treasuryVesters.push(address(vester));
            dyson.transfer(address(vester), vestingAmount);
            dyson.approve(address(sDyson), stakeAmount);
            sDyson.stake(recipients[i], stakeAmount, 126144000);  // locakDuration = 4 year (126144000 = 60*60*24*365*4)
        }

        // transfer ownership
        dyson.transferOwnership(owner);

        console.log("%s", "done");
        console.log("{");
        for (uint i = 0; i < treasuryVesters.length; ++i) {
            console.log("\"TreasuryVester%s\": \"%s\",", i, address(treasuryVesters[i]));
        }
        vm.stopBroadcast();
    }

}