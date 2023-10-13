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
import "../util/TreasuryVester.sol";
import "../util/FeeDistributor.sol";
import "../util/TokenSender.sol";
import "../util/AddressBook.sol";
import "../util/Faucet.sol";
import "../util/USDC.sol";
import "../util/WBTC.sol";
import "../util/TreasuryVester.sol";
import "interface/IERC20.sol";
import "interface/IWETH.sol";
import "./Addresses.sol";
import "forge-std/Test.sol";

contract TestnetDeployScriptPart2 is Addresses, Test {

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
    uint constant public WETH_PAIR_WETH_LIQUIDITY = 0.1 ether;
    uint constant public WETH_PAIR_USDC_LIQUIDITY = 160e6;

    Agency public agency;
    GaugeFactory public gaugeFactory;
    BribeFactory public bribeFactory;
    StakingRateModel public rateModel;
    Farm public farm;
    TreasuryVester public vester;
    address public wethFeeDistributor;
    address public wbtcFeeDistributor;
    address public dysnFeeDistributor;
    address public dysonGauge;
    address public dysonBribe;
    address public wethGauge;
    address public wethBribe; 
    address public wbtcGauge;
    address public wbtcBribe;
    address public vesterRecipient;

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
    uint constant public WBTC_PAIR_WBTC_LIQUIDITY = 100e8;
    uint constant public WBTC_PAIR_USDC_LIQUIDITY = 2500000e6; // 2.5M USD
    uint constant public DYSN_PAIR_DYSN_LIQUIDITY = 1000000e18; // 1M DYSN
    uint constant public DYSN_PAIR_USDC_LIQUIDITY = 250000e6; // 250K USD

    // TreasuryVester configs
    uint public vestingBegin = block.timestamp + 100;
    uint public vestingCliff = vestingBegin + 86400; // 1 day
    uint public vestingEnd = vestingCliff + 86400 * 2; // 2 days
    uint public vestingAmount = 1000e18; // 1000 DYSN

    function run() external {
        weth = IWETH(getAddress("WETH"));
        dyson = DYSON(getAddress("DYSON"));
        sDyson = sDYSON(getAddress("sDYSON"));
        factory = Factory(getAddress("factory"));
        router = Router(payable(getAddress("router")));
        addressBook = AddressBook(getAddress("addressBook"));
        tokenSender = TokenSender(getAddress("tokenSender"));
        weth_usdc_pair = Pair(getAddress("wethUsdcPair"));
        faucet = Faucet(getAddress("faucet"));
        usdc = USDC(getAddress("USDC"));
        wbtc = WBTC(getAddress("WBTC"));
        vesterRecipient = getAddress("vesterRecipient");

        address owner = vm.envAddress("OWNER_ADDRESS");
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        // ------------ Deploy all contracts ------------
        vester = new TreasuryVester(address(dyson), vesterRecipient, vestingAmount, vestingBegin, vestingCliff, vestingEnd);
        
        agency = new Agency(deployer, owner);
 
        gaugeFactory = new GaugeFactory(deployer);
        bribeFactory = new BribeFactory(deployer);
        
        rateModel = new StakingRateModel(initialRate);

        farm = new Farm(deployer, address(agency), address(dyson));

        dysn_usdc_pair = Pair(factory.createPair(address(dyson), address(usdc)));
        wbtc_usdc_pair = Pair(factory.createPair(address(wbtc), address(usdc)));
        
        dysonGauge = gaugeFactory.createGauge(address(farm), address(sDyson), address(dysn_usdc_pair), WEIGHT_DYSN, BASE, SLOPE);
        dysonBribe = bribeFactory.createBribe(dysonGauge);
        
        wethGauge = gaugeFactory.createGauge(address(farm), address(sDyson), address(weth_usdc_pair), WEIGHT_WETH, BASE, SLOPE);
        wethBribe = bribeFactory.createBribe(wethGauge);
        
        wbtcGauge = gaugeFactory.createGauge(address(farm), address(sDyson), address(wbtc_usdc_pair), WEIGHT_WBTC, BASE, SLOPE);
        wbtcBribe = bribeFactory.createBribe(wbtcGauge);
        
        wethFeeDistributor = address(new FeeDistributor(owner, address(weth_usdc_pair), address(wethBribe), owner, feeRateToDao));
        wbtcFeeDistributor = address(new FeeDistributor(owner, address(wbtc_usdc_pair), address(wbtcBribe), owner, feeRateToDao));
        dysnFeeDistributor = address(new FeeDistributor(owner, address(dysn_usdc_pair), address(dysonBribe), owner, feeRateToDao));

        // ------------ Setup configs ------------
        agency.addController(address(faucet));
        dyson.addMinter(address(farm));

        // Fund pairs
        usdc.approve(address(tokenSender), WBTC_PAIR_USDC_LIQUIDITY + DYSN_PAIR_USDC_LIQUIDITY);
        wbtc.approve(address(tokenSender), WBTC_PAIR_WBTC_LIQUIDITY);
        dyson.approve(address(tokenSender), DYSN_PAIR_DYSN_LIQUIDITY);
        wbtc.mint(deployer, WBTC_PAIR_WBTC_LIQUIDITY); // 100 WBTC
        dyson.mint(deployer, DYSN_PAIR_DYSN_LIQUIDITY); // 1M DYSN
        tokenSender.sendToken(address(wbtc), address(usdc), address(wbtc_usdc_pair), WBTC_PAIR_WBTC_LIQUIDITY, WBTC_PAIR_USDC_LIQUIDITY); // 2.5 M usdc
        tokenSender.sendToken(address(dyson), address(usdc), address(dysn_usdc_pair), DYSN_PAIR_DYSN_LIQUIDITY, DYSN_PAIR_USDC_LIQUIDITY); // 250 K usdc

        weth_usdc_pair.setFeeTo(wethFeeDistributor);   
        wbtc_usdc_pair.setFeeTo(wbtcFeeDistributor);
        dysn_usdc_pair.setFeeTo(dysnFeeDistributor);  

        sDyson.setStakingRateModel(address(rateModel));
        sDyson.transferOwnership(owner);

        dysn_usdc_pair.setFarm(address(farm));
        weth_usdc_pair.setFarm(address(farm));
        wbtc_usdc_pair.setFarm(address(farm));

        farm.setPool(address(dysn_usdc_pair), dysonGauge);
        farm.setPool(address(weth_usdc_pair), wethGauge);
        farm.setPool(address(wbtc_usdc_pair), wbtcGauge);

        farm.setGlobalRewardRate(GLOBALRATE, GLOBALWEIGHT);

        faucet.set(address(dyson), address(usdc), address(wbtc), address(agency));

        addressBook.file("farm", address(farm));
        addressBook.file("agentNFT", address(agency.agentNFT()));
        addressBook.file("agency", address(agency));
        addressBook.setBribeOfGauge(address(dysonGauge), address(dysonBribe));
        addressBook.setBribeOfGauge(address(wbtcGauge), address(wbtcBribe));
        addressBook.setBribeOfGauge(address(wethGauge), address(wethBribe));
        addressBook.setCanonicalIdOfPair(address(dyson), address(usdc), 1);
        addressBook.setCanonicalIdOfPair(address(wbtc), address(usdc), 1);

        router.rely(address(wbtc), address(wbtc_usdc_pair), true); // WBTC for wbtc_usdc_pair
        router.rely(address(usdc), address(wbtc_usdc_pair), true); // USDC for wbtc_usdc_pair
        router.rely(address(dyson), address(dysn_usdc_pair), true); // DYSN for dysn_usdc_pair
        router.rely(address(usdc), address(dysn_usdc_pair), true); // USDC for dysn_usdc_pair
        router.rely(address(sDyson), address(dysonGauge), true);
        router.rely(address(sDyson), address(wbtcGauge), true);
        router.rely(address(sDyson), address(wethGauge), true);
        router.rely(address(dyson), address(sDyson), true);

        agency.transferOwnership(owner);
        farm.transferOwnership(owner);
        dyson.transferOwnership(owner);
        wbtc.transferOwnership(owner);
        faucet.transferOwnership(owner);
        addressBook.file("owner", owner);
        router.transferOwnership(owner);
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
        console.log("\"%s\": \"%s\"", "weth_usdc_pair", address(weth_usdc_pair));
        console.log("},");
        console.log("\"other\": {");
        console.log("\"%s\": \"%s\",", "dysn_usdc_gauge", address(dysonGauge));
        console.log("\"%s\": \"%s\",", "dysn_usdc_bribe", address(dysonBribe));
        console.log("\"%s\": \"%s\",", "wbtc_usdc_gauge", address(wbtcGauge));
        console.log("\"%s\": \"%s\",", "wbtc_usdc_bribe", address(wbtcBribe));
        console.log("\"%s\": \"%s\",", "weth_usdc_gauge", address(wethGauge));
        console.log("\"%s\": \"%s\",", "weth_usdc_bribe", address(wethBribe));
        console.log("\"%s\": \"%s\",", "dysn_usdc_feeDistributor", address(dysnFeeDistributor));
        console.log("\"%s\": \"%s\",", "wbtc_usdc_feeDistributor", address(wbtcFeeDistributor));
        console.log("\"%s\": \"%s\",", "weth_usdc_feeDistributor", address(wethFeeDistributor));
        console.log("\"%s\": \"%s\",", "treasuryVester", address(vester));
        console.log("\"%s\": \"%s\",", "treasuryVesterRecipient", address(vesterRecipient));
        console.log("\"%s\": \"%s\"", "tokenSender", address(tokenSender));
        console.log("}");
        console.log("}");

        vm.stopBroadcast();
    }
}