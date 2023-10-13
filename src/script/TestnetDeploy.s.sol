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

contract TestnetDeployScript is Addresses, Test {
    Agency public agency;
    DYSON public dyson;
    sDYSON public sDyson;
    Factory public factory;
    GaugeFactory public gaugeFactory;
    BribeFactory public bribeFactory;
    Router public router;
    StakingRateModel public rateModel;
    Farm public farm;
    Faucet public faucet;
    AddressBook public addressBook; 
    TokenSender public tokenSender;
    address public wethFeeDistributor;
    address public wbtcFeeDistributor;
    address public dysnFeeDistributor;
    address public dysonGauge;
    address public dysonBribe;
    address public wethGauge;
    address public wethBribe; 
    address public wbtcGauge;
    address public wbtcBribe;

    USDC public usdc;
    WBTC public wbtc;
    IWETH weth;

    Pair public weth_usdc_pair;
    Pair public wbtc_usdc_pair;
    Pair public dysn_usdc_pair;

    uint constant public WEIGHT_DYSN = 102750e12; // sqrt(1250000e6*5000000e18) * 0.00274 *15
    uint constant public WEIGHT_WETH = 1284e12; // ETH price = 1600USD, so W = sqrt(1250000e6*781e18) * 0.00274 *15
    uint constant public WEIGHT_WBTC = 325e7; // BTC price = 25000USD, so W = sqrt(1250000e6*50e8) * 0.00274 *15
    uint constant public BASE = 0.17e18; // 0.5 / 3
    uint constant public SLOPE = 0.00000009e18;
    uint constant public GLOBALRATE = 0.951e18;
    uint constant public GLOBALWEIGHT = 821917e18;

    // Configs for StakingRateModel
    uint initialRate = 0.0625e18;

    // Fee rate to DAO wallet
    uint public feeRateToDao = 0.5e18;

    // initial liquidity
    uint constant public WETHPAIR_WETH_LIQUIDITY = 1 ether;
    uint constant public WETHPAIR_USDC_LIQUIDITY = 1600e6;
    uint constant public WBTCPAIR_WBTC_LIQUIDITY = 100e8;
    uint constant public WBTCPAIR_USDC_LIQUIDITY = 2500000e6; // 2.5M USD
    uint constant public DYSNPAIR_DYSN_LIQUIDITY = 1000000e18; // 1M DYSN
    uint constant public DYSNPAIR_USDC_LIQUIDITY = 250000e6; // 250K USD

    function run() external {
        weth = IWETH(getAddress("WETH"));
        address owner = vm.envAddress("OWNER_ADDRESS");
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);
        console.log("%s: %s", "weth", address(weth));

        // ------------ Deploy all contracts ------------

        // Deploy TokenSender
        tokenSender = new TokenSender();

        // Deploy Faucet
        faucet = new Faucet(deployer);
        console.log("%s: %s", "faucet", address(faucet));

        // Deploy Agency
        agency = new Agency(deployer, owner);
        console.log("%s: %s", "agency", address(agency));

        // Deploy USDC and WBTC
        usdc = new USDC(deployer);
        wbtc = new WBTC(deployer);
        console.log("%s: %s", "usdc", address(usdc));
        console.log("%s: %s", "wbtc", address(wbtc));

        // Deploy Dyson, sDyson, Factory and Router
        dyson = new DYSON(deployer);
        sDyson = new sDYSON(deployer, address(dyson));
        factory = new Factory(deployer);
        gaugeFactory = new GaugeFactory(deployer);
        bribeFactory = new BribeFactory(deployer);
        router = new Router(address(weth), deployer, address(factory), address(sDyson), address(dyson));
        console.log("%s: %s", "dyson", address(dyson));
        console.log("%s: %s", "sDyson", address(sDyson));
        console.log("%s: %s", "factory", address(factory));
        console.log("%s: %s", "router", address(router));

        // Deploy StakingRateModel
        rateModel = new StakingRateModel(initialRate);
        console.log("%s: %s", "rateModel", address(rateModel));

        // Deploy Farm
        farm = new Farm(deployer, address(agency), address(dyson));
        console.log("%s: %s", "farm", address(farm));

        // Create pairs
        dysn_usdc_pair = Pair(factory.createPair(address(dyson), address(usdc)));
        weth_usdc_pair = Pair(factory.createPair(address(weth), address(usdc)));
        wbtc_usdc_pair = Pair(factory.createPair(address(wbtc), address(usdc)));
        console.log("%s: %s", "dysn_usdc_pair", address(dysn_usdc_pair));
        console.log("%s: %s", "weth_usdc_pair", address(weth_usdc_pair));
        console.log("%s: %s", "wbtc_usdc_pair", address(wbtc_usdc_pair));

        // Deploy Gauges and Bribes
        dysonGauge = gaugeFactory.createGauge(address(farm), address(sDyson), address(dysn_usdc_pair), WEIGHT_DYSN, BASE, SLOPE);
        dysonBribe = bribeFactory.createBribe(dysonGauge);
        console.log("%s: %s", "dysn_usdc_pair gauge", address(dysonGauge));
        console.log("%s: %s", "dysn_usdc_pair bribe", address(dysonBribe));

        wethGauge = gaugeFactory.createGauge(address(farm), address(sDyson), address(weth_usdc_pair), WEIGHT_WETH, BASE, SLOPE);
        wethBribe = bribeFactory.createBribe(wethGauge);
        console.log("%s: %s", "weth_usdc_pair gauge", address(wethGauge));
        console.log("%s: %s", "weth_usdc_pair bribe", address(wethBribe));

        wbtcGauge = gaugeFactory.createGauge(address(farm), address(sDyson), address(wbtc_usdc_pair), WEIGHT_WBTC, BASE, SLOPE);
        wbtcBribe = bribeFactory.createBribe(wbtcGauge);
        console.log("%s: %s", "wbtc_usdc_pair gauge", address(wbtcGauge));
        console.log("%s: %s", "wbtc_usdc_pair bribe", address(wbtcBribe));

        // Deploy FeeDistributor
        wethFeeDistributor = address(new FeeDistributor(owner, address(weth_usdc_pair), address(wethBribe), owner, feeRateToDao));
        wbtcFeeDistributor = address(new FeeDistributor(owner, address(wbtc_usdc_pair), address(wbtcBribe), owner, feeRateToDao));
        dysnFeeDistributor = address(new FeeDistributor(owner, address(dysn_usdc_pair), address(dysonBribe), owner, feeRateToDao));

        // Deploy AddressBook
        addressBook = new AddressBook(deployer);

        // ------------ Setup configs ------------
        // Setup minters
        agency.addController(address(faucet));
        dyson.addMinter(address(farm));
        dyson.addMinter(address(faucet));
        usdc.addMinter(address(faucet));
        wbtc.addMinter(address(faucet));

        // Fund pairs
        usdc.approve(address(tokenSender), WETHPAIR_USDC_LIQUIDITY + WBTCPAIR_USDC_LIQUIDITY + DYSNPAIR_USDC_LIQUIDITY);
        weth.approve(address(tokenSender), WETHPAIR_WETH_LIQUIDITY);
        wbtc.approve(address(tokenSender), WBTCPAIR_WBTC_LIQUIDITY);
        dyson.approve(address(tokenSender), DYSNPAIR_DYSN_LIQUIDITY);

        weth.deposit{value : 1 ether}();
        usdc.mint(deployer, 1e18); // 1e12 USDC
        wbtc.mint(deployer, WBTCPAIR_WBTC_LIQUIDITY); // 100 WBTC
        dyson.mint(deployer, DYSNPAIR_DYSN_LIQUIDITY); // 1M DYSN
        tokenSender.sendToken(address(weth), address(usdc), address(weth_usdc_pair), WETHPAIR_WETH_LIQUIDITY, WETHPAIR_USDC_LIQUIDITY); // 1600 usdc
        tokenSender.sendToken(address(wbtc), address(usdc), address(wbtc_usdc_pair), WBTCPAIR_WBTC_LIQUIDITY, WBTCPAIR_USDC_LIQUIDITY); // 2.5 M usdc
        tokenSender.sendToken(address(dyson), address(usdc), address(dysn_usdc_pair), DYSNPAIR_DYSN_LIQUIDITY, DYSNPAIR_USDC_LIQUIDITY); // 250 K usdc

        // set feeTo to pairs
        weth_usdc_pair.setFeeTo(wethFeeDistributor);   
        wbtc_usdc_pair.setFeeTo(wbtcFeeDistributor);
        dysn_usdc_pair.setFeeTo(dysnFeeDistributor);  

        // Setup sDyson
        sDyson.setStakingRateModel(address(rateModel));
        sDyson.transferOwnership(owner);

        // Setup farm
        dysn_usdc_pair.setFarm(address(farm));
        weth_usdc_pair.setFarm(address(farm));
        wbtc_usdc_pair.setFarm(address(farm));

        // Setup gauge and bribe
        farm.setPool(address(dysn_usdc_pair), dysonGauge);
        farm.setPool(address(weth_usdc_pair), wethGauge);
        farm.setPool(address(wbtc_usdc_pair), wbtcGauge);

        // Setup global reward rate
        farm.setGlobalRewardRate(GLOBALRATE, GLOBALWEIGHT);

        // Setup Faucet
        faucet.set(address(dyson), address(usdc), address(wbtc), address(agency));

        addressBook.file("govToken", address(dyson));
        addressBook.file("govTokenStaking", address(sDyson));
        addressBook.file("factory", address(factory));
        addressBook.file("router", address(router));
        addressBook.file("farm", address(farm));
        addressBook.file("agentNFT", address(agency.agentNFT()));
        addressBook.file("agency", address(agency));
        addressBook.setBribeOfGauge(address(dysonGauge), address(dysonBribe));
        addressBook.setBribeOfGauge(address(wbtcGauge), address(wbtcBribe));
        addressBook.setBribeOfGauge(address(wethGauge), address(wethBribe));
        addressBook.setCanonicalIdOfPair(address(dyson), address(usdc), 1);
        addressBook.setCanonicalIdOfPair(address(wbtc), address(usdc), 1);
        addressBook.setCanonicalIdOfPair(address(weth), address(usdc), 1);

        // rely token to router
        router.rely(address(wbtc), address(wbtc_usdc_pair), true); // WBTC for wbtc_usdc_pair
        router.rely(address(usdc), address(wbtc_usdc_pair), true); // USDC for wbtc_usdc_pair
        router.rely(address(weth), address(weth_usdc_pair), true); // WETH for weth_usdc_pair
        router.rely(address(usdc), address(weth_usdc_pair), true); // USDC for weth_usdc_pair
        router.rely(address(dyson), address(dysn_usdc_pair), true); // DYSN for dysn_usdc_pair
        router.rely(address(usdc), address(dysn_usdc_pair), true); // USDC for dysn_usdc_pair
        router.rely(address(sDyson), address(dysonGauge), true);
        router.rely(address(sDyson), address(wbtcGauge), true);
        router.rely(address(sDyson), address(wethGauge), true);
        router.rely(address(dyson), address(sDyson), true);

        // transfer ownership
        addressBook.file("owner", owner);
        agency.transferOwnership(owner);
        dyson.transferOwnership(owner);
        usdc.transferOwnership(owner);
        wbtc.transferOwnership(owner);
        factory.setController(owner);
        farm.transferOwnership(owner);
        router.transferOwnership(owner);
        faucet.transferOwnership(owner);

        // Set addressBook address to deploy-config.json to feed DysonToGoFactoryDeploy.s.sol
        setAddress(address(addressBook), "addressBook");
        
        console.log("%s", "done");
        
        console.log("{");
        console.log("\"%s\": \"%s\",", "addressBook", address(addressBook));
        console.log("\"%s\": \"%s\",", "wrappedNativeToken", address(weth));
        console.log("\"%s\": \"%s\",", "faucet", address(faucet));
        console.log("\"%s\": \"%s\",", "agency", address(agency));
        console.log("\"%s\": \"%s\",", "pairFactory", address(factory));
        console.log("\"%s\": \"%s\",", "gaugeFactory", address(gaugeFactory));
        console.log("\"%s\": \"%s\",", "bribeFactory", address(bribeFactory));
        console.log("\"%s\": \"%s\",", "router", address(router));
        console.log("\"%s\": \"%s\",", "sDyson", address(sDyson));
        console.log("\"%s\": \"%s\",", "farm", address(farm));
        console.log("\"tokens\": {");
        console.log("\"%s\": \"%s\",", "DYSN", address(dyson));
        console.log("\"%s\": \"%s\",", "WBTC", address(wbtc));
        console.log("\"%s\": \"%s\",", "WETH", address(weth));
        console.log("\"%s\": \"%s\"", "USDC", address(usdc));
        console.log("},");
        console.log("\"baseTokenPair\": {");
        console.log("\"%s\": \"%s\",", "dyson_usdc_pair", address(dysn_usdc_pair));
        console.log("\"%s\": \"%s\",", "wbtc_usdc_pair", address(wbtc_usdc_pair));
        console.log("\"%s\": \"%s\",", "weth_usdc_pair", address(weth_usdc_pair));
        console.log("}");
        console.log("\"other\": {");
        console.log("\"%s\": \"%s\",", "dysn_usdc_gauge", address(dysonGauge));
        console.log("\"%s\": \"%s\",", "dysn_usdc_bribe", address(dysonBribe));
        console.log("\"%s\": \"%s\",", "wbtc_usdc_gauge", address(wbtcGauge));
        console.log("\"%s\": \"%s\",", "wbtc_usdc_bribe", address(wbtcBribe));
        console.log("\"%s\": \"%s\",", "weth_usdc_gauge", address(wethGauge));
        console.log("\"%s\": \"%s\"", "weth_usdc_bribe", address(wethBribe));
        console.log("}");
        console.log("\"contract side\": {");
        console.log("\"%s\": \"%s\",", "tokenSender", address(tokenSender));
        console.log("}");

        vm.stopBroadcast();
    }
}