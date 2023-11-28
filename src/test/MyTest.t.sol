// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "src/Pair.sol";
import "src/Factory.sol";
import "src/DYSON.sol";
import "src/sDYSON.sol";
import "src/Gauge.sol";
import "src/Agency.sol";
import "src/AgentNFT.sol";
import "src/Farm.sol";
import "src/Bribe.sol";
import "src/interface/IERC20.sol";
import "src/interface/IWETH.sol";
import "src/util/AddressBook.sol";
import "src/DysonToGo.sol";
import "./TestUtils.sol";
import "../lib/ABDKMath64x64.sol";

contract MyTest is TestUtils {

    function setUp() public {
        string memory rpcUrl = vm.rpcUrl("polygonZKEVM");
        vm.createSelectFork(rpcUrl);

        address wethPair = 0xEce7244a0e861C841651401fC22cEE577fEE90AF; // token0 = weth, token1 = usdc
        address user = 0x3854e1450e6eDC5Fe8526A8daf8f48Efc259f9fF;

        
        // console.log("--------------------Balance:", balance);
        vm.prank(user);
        Pair(wethPair).deposit1(user, 1e6, 0, 86400);

    }

    function testSomething() public {}
}

    

    

    