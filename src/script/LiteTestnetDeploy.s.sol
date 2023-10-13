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
import "../util/FeeDistributor.sol";
import "../util/TokenSender.sol";
import "../util/AddressBook.sol";
import "../util/Faucet.sol";
import "../util/USDC.sol";
import "../util/WBTC.sol";
import "interface/IERC20.sol";
import "interface/IWETH.sol";
import "./Addresses.sol";
import "forge-std/Test.sol";

contract LiteTestnetDeployScript is Addresses, Test {
    DYSON public dyson;
    sDYSON public sDyson;
    Factory public factory;
    Router public router;
    AddressBook public addressBook; 
    TokenSender public tokenSender;
    Pair public weth_usdc_pair;
    Faucet public faucet;
    USDC public usdc;
    WBTC public wbtc;
    IWETH weth;

    // initial liquidity
    uint constant public WETH_PAIR_WETH_LIQUIDITY = 0.01 ether;
    uint constant public WETH_PAIR_USDC_LIQUIDITY = 16e6;

    function run() external {
        weth = IWETH(getAddress("WETH"));
        address owner = vm.envAddress("OWNER_ADDRESS");
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);
        console.log("%s: %s", "weth", address(weth));

        // ------------ Deploy all contracts ------------
        // Deploy USDC
        usdc = new USDC(deployer);
        console.log("%s: %s", "usdc", address(usdc));
        wbtc = new WBTC(deployer);
        console.log("%s: %s", "wbtc", address(wbtc));

        // Deploy DYSON, sDYSON, Factory and Router
        dyson = new DYSON(deployer);
        sDyson = new sDYSON(deployer, address(dyson));
        factory = new Factory(deployer);
        router = new Router(address(weth), deployer, address(factory), address(sDyson), address(dyson));
        console.log("%s: %s", "factory", address(factory));
        console.log("%s: %s", "router", address(router));

        // Create pairs
        weth_usdc_pair = Pair(factory.createPair(address(weth), address(usdc)));
        console.log("%s: %s", "weth_usdc_pair", address(weth_usdc_pair));

        // Deploy AddressBook
        addressBook = new AddressBook(deployer);

        // Deploy TokenSender
        tokenSender = new TokenSender();

        // Deploy Faucet
        faucet = new Faucet(deployer);
        console.log("%s: %s", "faucet", address(faucet));

        // ------------ Setup configs ------------
        // Setup minters
        usdc.addMinter(address(faucet));
        dyson.addMinter(address(faucet));
        wbtc.addMinter(address(faucet));

        // Fund pairs
        usdc.approve(address(tokenSender), WETH_PAIR_USDC_LIQUIDITY);
        weth.approve(address(tokenSender), WETH_PAIR_WETH_LIQUIDITY);
        
        weth.deposit{value : WETH_PAIR_WETH_LIQUIDITY}();
        usdc.mint(deployer, 1e18); // 1e12 USDC
        tokenSender.sendToken(address(weth), address(usdc), address(weth_usdc_pair), WETH_PAIR_WETH_LIQUIDITY, WETH_PAIR_USDC_LIQUIDITY); // 1600 usdc

        // Setup Faucet
        faucet.set(address(dyson), address(usdc), address(wbtc), address(0));
        
        addressBook.file("govToken", address(dyson));
        addressBook.file("govTokenStaking", address(sDyson));
        addressBook.file("factory", address(factory));
        addressBook.file("router", address(router));
        addressBook.setCanonicalIdOfPair(address(weth), address(usdc), 1);

        // rely token to router
        router.rely(address(weth), address(weth_usdc_pair), true); // WETH for weth_usdc_pair
        router.rely(address(usdc), address(weth_usdc_pair), true); // USDC for weth_usdc_pair

        // transfer ownership
        usdc.transferOwnership(owner);
        factory.setController(owner);

        // Set addressBook address to deploy-config.json to feed DysonToGoFactoryDeploy.s.sol
        setAddress(address(addressBook), "addressBook");
        setAddress(address(dyson), "DYSON");
        setAddress(address(sDyson), "sDYSON");
        setAddress(address(factory), "factory");
        setAddress(address(router), "router");
        setAddress(address(faucet), "faucet");
        setAddress(address(weth_usdc_pair), "wethUsdcPair");
        setAddress(address(usdc), "USDC");
        setAddress(address(wbtc), "WBTC");
        setAddress(address(tokenSender), "tokenSender");
        console.log("%s", "done");
        
        console.log("{");
        console.log("\"%s\": \"%s\",", "addressBook", address(addressBook));
        console.log("\"%s\": \"%s\",", "wrappedNativeToken", address(weth));
        console.log("\"%s\": \"%s\",", "faucet", address(faucet));
        console.log("\"%s\": \"%s\",", "pairFactory", address(factory));
        console.log("\"%s\": \"%s\",", "router", address(router));
        console.log("\"%s\": \"%s\",", "sDyson", address(sDyson));
        console.log("\"tokens\": {");
        console.log("\"%s\": \"%s\",", "DYSN", address(dyson));
        console.log("\"%s\": \"%s\",", "WETH", address(weth));
        console.log("\"%s\": \"%s\"", "USDC", address(usdc));
        console.log("},");
        console.log("\"baseTokenPair\": {");
        console.log("\"%s\": \"%s\"", "weth_usdc_pair", address(weth_usdc_pair));
        console.log("},");
        console.log("\"other\": {");
        console.log("\"%s\": \"%s\",", "tokenSender", address(tokenSender));
        console.log("}");

        vm.stopBroadcast();
    }
}