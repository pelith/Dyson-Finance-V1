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
import "../util/FeeDistributor.sol";
import "interface/IERC20.sol";
import "./Addresses.sol";
import "./Amounts.sol";
import "forge-std/Test.sol";

contract MainnetDeployScriptPart2 is Addresses, Test {
    DYSON public dyson = DYSON(getAddress("DYSON"));
    sDYSON public sDyson = sDYSON(getAddress("sDYSON"));
    Factory public factory = Factory(getAddress("factory"));
    Router public router = Router(payable(getAddress("router")));
    AddressBook public addressBook = AddressBook(getAddress("addressBook"));
    TokenSender public tokenSender = TokenSender(getAddress("tokenSender"));
    Pair public weth_usdc_pair = Pair(getAddress("wethUsdcPair"));

    // Configs for Router
    address public weth = getOfficialAddress("WETH");
    address public usdc = getOfficialAddress("USDC");

    Agency public agency;
    GaugeFactory public gaugeFactory;
    BribeFactory public bribeFactory;
    StakingRateModel public rateModel;
    Farm public farm;
    address public wethFeeDistributor;
    address public dysnFeeDistributor;
    address public dysonGauge;
    address public dysonBribe;
    address public wethGauge;
    address public wethBribe; 

    Pair public dysn_usdc_pair;

    uint public constant WEIGHT_DYSN = 102750e12; // sqrt(1250000e6*5000000e18) * 0.00274 *15
    uint public constant WEIGHT_WETH = 1149e12; // ETH price = 2000USD, so W = sqrt(1250000e6*625e18) * 0.00274 *15
    uint public constant BASE = 0; // 0.17e18; // 0.5 / 3
    uint public constant SLOPE = 0.00000009e18;
    uint public constant GLOBALRATE = 0; // 0.951e18;
    uint public constant GLOBALWEIGHT = 821917e18;

    // Configs for StakingRateModel
    uint initialRate = 0.0625e18;

    // Fee rate to DAO wallet
    uint public feeRateToDao = 0.5e18;

    function run() external {
        address owner = vm.envAddress("OWNER_ADDRESS");
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);
        factory.becomeController();

        // ------------ Deploy all contracts ------------
        // Deploy Agency
        agency = new Agency(deployer, owner);

        // Deploy GaugeFactory and BribeFactory
        gaugeFactory = new GaugeFactory(deployer);
        bribeFactory = new BribeFactory(deployer);

        // Deploy StakingRateModel
        rateModel = new StakingRateModel(initialRate);

        // Deploy Farm
        farm = new Farm(deployer, address(agency), address(dyson));

        // Create pairs
        dysn_usdc_pair = Pair(factory.createPair(address(dyson), address(usdc)));

        // Deploy Gauges and Bribes
        dysonGauge = gaugeFactory.createGauge(address(farm), address(sDyson), address(dysn_usdc_pair), WEIGHT_DYSN, BASE, SLOPE);
        dysonBribe = bribeFactory.createBribe(dysonGauge);
        
        wethGauge = gaugeFactory.createGauge(address(farm), address(sDyson), address(weth_usdc_pair), WEIGHT_WETH, BASE, SLOPE);
        wethBribe = bribeFactory.createBribe(wethGauge);
        
        wethFeeDistributor = address(new FeeDistributor(owner, address(weth_usdc_pair), address(wethBribe), owner, feeRateToDao));
        dysnFeeDistributor = address(new FeeDistributor(owner, address(dysn_usdc_pair), address(dysonBribe), owner, feeRateToDao));

        // ------------ Setup configs ------------
        // Setup minters
        dyson.addMinter(address(farm));

        // Set feeTo
        weth_usdc_pair.setFeeTo(wethFeeDistributor);   
        dysn_usdc_pair.setFeeTo(dysnFeeDistributor);  
        
        // Setup sDyson
        sDyson.setStakingRateModel(address(rateModel));

        // Setup farm
        dysn_usdc_pair.setFarm(address(farm));
        weth_usdc_pair.setFarm(address(farm));

        // Setup gauge and bribe
        farm.setPool(address(dysn_usdc_pair), dysonGauge);
        farm.setPool(address(weth_usdc_pair), wethGauge);

        // Setup global reward rate
        farm.setGlobalRewardRate(GLOBALRATE, GLOBALWEIGHT);

        addressBook.file("farm", address(farm));
        addressBook.file("agentNFT", address(agency.agentNFT()));
        addressBook.file("agency", address(agency));
        addressBook.setBribeOfGauge(address(dysonGauge), address(dysonBribe));
        addressBook.setBribeOfGauge(address(wethGauge), address(wethBribe));
        addressBook.setCanonicalIdOfPair(address(dyson), address(usdc), 1);

        // rely token to router
        router.rely(address(dyson), address(dysn_usdc_pair), true); // DYSN for dysn_usdc_pair
        router.rely(address(usdc), address(dysn_usdc_pair), true); // USDC for dysn_usdc_pair
        router.rely(address(sDyson), address(dysonGauge), true);
        router.rely(address(sDyson), address(wethGauge), true);
        router.rely(address(dyson), address(sDyson), true);

        // transfer ownership
        addressBook.file("owner", owner);
        agency.transferOwnership(owner);
        dyson.transferOwnership(owner);
        factory.setController(owner);
        farm.transferOwnership(owner);
        router.transferOwnership(owner);
        sDyson.transferOwnership(owner);

        // --- After deployment, we need to config the following things: ---
        // Fund DYSON & USDC to dysn_usdc_pair
        // Fund WETH & USDC to weth_usdc_pair

        console.log("%s", "done");
        
        console.log("{");
        console.log("\"%s\": \"%s\",", "addressBook", address(addressBook));
        console.log("\"%s\": \"%s\",", "wrappedNativeToken", address(weth));
        console.log("\"%s\": \"%s\",", "agency", address(agency));
        console.log("\"%s\": \"%s\",", "dyson", address(dyson));
        console.log("\"%s\": \"%s\",", "pairFactory", address(factory));
        console.log("\"%s\": \"%s\",", "router", address(router));
        console.log("\"%s\": \"%s\",", "sDyson", address(sDyson));
        console.log("\"%s\": \"%s\",", "farm", address(farm));
        console.log("\"tokens\": {");
        console.log("\"%s\": \"%s\",", "WETH", address(weth));
        console.log("\"%s\": \"%s\"", "USDC", address(usdc));
        console.log("},");
        console.log("\"baseTokenPair\": {");
        console.log("\"%s\": \"%s\"", "dysonUsdcPair", address(dysn_usdc_pair));
        console.log("\"%s\": \"%s\",", "wethUsdcPair", address(weth_usdc_pair));
        console.log("},");
        console.log("\"other\": {");
        console.log("\"%s\": \"%s\",", "dysn_usdc_gauge", address(dysonGauge));
        console.log("\"%s\": \"%s\",", "dysn_usdc_bribe", address(dysonBribe));
        console.log("\"%s\": \"%s\",", "weth_usdc_gauge", address(wethGauge));
        console.log("\"%s\": \"%s\",", "weth_usdc_bribe", address(wethBribe));
        console.log("\"%s\": \"%s\",", "dysn_usdc_feeDistributor", address(dysnFeeDistributor));
        console.log("\"%s\": \"%s\",", "weth_usdc_feeDistributor", address(wethFeeDistributor));
        console.log("\"%s\": \"%s\"", "tokenSender", address(tokenSender));
        console.log("}");
        console.log("}");

        vm.stopBroadcast();
    }

}