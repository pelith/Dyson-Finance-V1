// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../../script/TestnetDeploy.s.sol";
import "../../script/Addresses.sol";
import "src/util/WETH.sol";
import "src/util/USDC.sol";
import "src/util/WBTC.sol";
import "src/util/Faucet.sol";
import "src/util/AddressBook.sol";
import "interface/IsDYSON.sol";
import "interface/IPair.sol";
import "interface/IGauge.sol";
import "interface/IBribe.sol";
import "interface/IDYSON.sol";
import "interface/IFactory.sol";
import "interface/IAgency.sol";
import "interface/IFarm.sol";
import "interface/IFeeDistributor.sol";
import "interface/IRouter.sol";
import "../TestUtils.sol";

contract TestnetDeployTest is Addresses, TestUtils {
    TestnetDeployScript script;

    address owner = vm.envAddress("OWNER_ADDRESS");
    uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
    address deployer = vm.addr(deployerPrivateKey);
    address payable weth;
    address usdc;
    address wbtc;
    address dyson;
    address sDyson;
    address factory;
    address agency; 
    address farm;
    address addressBook;
    address router;
    address faucet;
    IGauge dysonGauge;
    IBribe dysonBribe;
    IGauge wethGauge;
    IBribe wethBribe; 
    IGauge wbtcGauge;
    IBribe wbtcBribe;
    

    uint WETHPAIR_WETH_LIQUIDITY;
    uint WETHPAIR_USDC_LIQUIDITY;
    uint WBTCPAIR_WBTC_LIQUIDITY;
    uint WBTCPAIR_USDC_LIQUIDITY;
    uint DYSNPAIR_DYSN_LIQUIDITY;
    uint DYSNPAIR_USDC_LIQUIDITY;
    uint WEIGHT_DYSN;
    uint WEIGHT_WETH;
    uint WEIGHT_WBTC;
    uint BASE;
    uint SLOPE;
    uint GLOBALRATE;
    uint GLOBALWEIGHT;

    address weth_usdc_pair;
    address wbtc_usdc_pair;
    address dysn_usdc_pair;
    address alice = _nameToAddr("alice");

    function setUp() public {
        weth = payable(address(new WETH()));
        vm.deal(deployer, 100 ether);

        // Apply WETH address to deploy-config.json to feed TestnetDeployScript
        setAddress(address(weth), "WETH");

        script = new TestnetDeployScript();
        script.run();
        usdc = address(script.usdc());
        wbtc = address(script.wbtc());
        dyson = address(script.dyson());
        sDyson = address(script.sDyson());
        weth_usdc_pair = address(script.weth_usdc_pair());
        wbtc_usdc_pair = address(script.wbtc_usdc_pair());
        dysn_usdc_pair = address(script.dysn_usdc_pair());
        factory = address(script.factory());
        agency = address(script.agency());
        farm = address(script.farm());
        addressBook = address(script.addressBook());
        router = address(script.router());
        faucet = address(script.faucet());

        // initial liquidity
        WETHPAIR_WETH_LIQUIDITY = script.WETHPAIR_WETH_LIQUIDITY();
        WETHPAIR_USDC_LIQUIDITY = script.WETHPAIR_USDC_LIQUIDITY();
        WBTCPAIR_WBTC_LIQUIDITY = script.WBTCPAIR_WBTC_LIQUIDITY();
        WBTCPAIR_USDC_LIQUIDITY = script.WBTCPAIR_USDC_LIQUIDITY(); 
        DYSNPAIR_DYSN_LIQUIDITY = script.DYSNPAIR_DYSN_LIQUIDITY(); 
        DYSNPAIR_USDC_LIQUIDITY = script.DYSNPAIR_USDC_LIQUIDITY(); 
        WEIGHT_DYSN = script.WEIGHT_DYSN();
        WEIGHT_WETH = script.WEIGHT_WETH();
        WEIGHT_WBTC = script.WEIGHT_WBTC();
        BASE = script.BASE();
        SLOPE = script.SLOPE();
        GLOBALRATE = script.GLOBALRATE();
        GLOBALWEIGHT = script.GLOBALWEIGHT();
        dysonGauge = IGauge(script.dysonGauge());
        dysonBribe = IBribe(script.dysonBribe());
        wethGauge = IGauge(script.wethGauge());
        wethBribe = IBribe(script.wethBribe());
        wbtcGauge = IGauge(script.wbtcGauge());
        wbtcBribe = IBribe(script.wbtcBribe());
    }

    function testContractSetup() public {

        // Router Params check
        assertEq(script.router().WETH(), weth);
        assertEq(script.router().sDYSON(), sDyson);
        assertEq(script.router().DYSON(), dyson);
        assertEq(script.router().DYSON_FACTORY(), factory);

        // Agency params check
        assertEq(IAgency(agency).whois(owner), 1); // check root agent = owner

        // Farm params check
        assertEq(address(IFarm(farm).gov()), dyson);
        assertEq(address(IFarm(farm).agency()), agency);

        // Gauges params check
        assertEq(address(dysonGauge.farm()), farm);
        assertEq(dysonGauge.SGOV(), sDyson);
        assertEq(dysonGauge.poolId(), dysn_usdc_pair);
        assertEq(dysonGauge.weight(), WEIGHT_DYSN);
        assertEq(dysonGauge.base(), BASE);
        assertEq(dysonGauge.slope(), SLOPE);

        assertEq(address(wethGauge.farm()), farm);
        assertEq(wethGauge.SGOV(), sDyson);
        assertEq(wethGauge.poolId(), weth_usdc_pair);
        assertEq(wethGauge.weight(), WEIGHT_WETH);
        assertEq(wethGauge.base(), BASE);
        assertEq(wethGauge.slope(), SLOPE);

        assertEq(address(wbtcGauge.farm()), farm);
        assertEq(wbtcGauge.SGOV(), sDyson);
        assertEq(wbtcGauge.poolId(), wbtc_usdc_pair);
        assertEq(wbtcGauge.weight(), WEIGHT_WBTC);
        assertEq(wbtcGauge.base(), BASE);
        assertEq(wbtcGauge.slope(), SLOPE);

        // FeeDistributor params check
        assertEq(IFeeDistributor(script.wethFeeDistributor()).owner(), owner);
        assertEq(IFeeDistributor(script.wethFeeDistributor()).pair(), weth_usdc_pair);
        assertEq(IFeeDistributor(script.wethFeeDistributor()).bribe(), address(wethBribe));
        assertEq(IFeeDistributor(script.wethFeeDistributor()).daoWallet(), owner);
        assertEq(IFeeDistributor(script.wethFeeDistributor()).feeRateToDao(), script.feeRateToDao());

        assertEq(IFeeDistributor(script.wbtcFeeDistributor()).owner(), owner);
        assertEq(IFeeDistributor(script.wbtcFeeDistributor()).pair(), wbtc_usdc_pair);
        assertEq(IFeeDistributor(script.wbtcFeeDistributor()).bribe(), address(wbtcBribe));
        assertEq(IFeeDistributor(script.wbtcFeeDistributor()).daoWallet(), owner);
        assertEq(IFeeDistributor(script.wbtcFeeDistributor()).feeRateToDao(), script.feeRateToDao());

        assertEq(IFeeDistributor(script.dysnFeeDistributor()).owner(), owner);
        assertEq(IFeeDistributor(script.dysnFeeDistributor()).pair(), dysn_usdc_pair);
        assertEq(IFeeDistributor(script.dysnFeeDistributor()).bribe(), address(dysonBribe));
        assertEq(IFeeDistributor(script.dysnFeeDistributor()).daoWallet(), owner);
        assertEq(IFeeDistributor(script.dysnFeeDistributor()).feeRateToDao(), script.feeRateToDao());

        // Minter check
        assertEq(IAgency(agency).isController(faucet), true);
        assertEq(IDYSON(dyson).isMinter(address(farm)), true);
        assertEq(IDYSON(dyson).isMinter(faucet), true);
        assertEq(USDC(usdc).isMinter(faucet), true);
        assertEq(WBTC(wbtc).isMinter(faucet), true);

        // Pair params check
        assertEq(IPair(weth_usdc_pair).feeTo(), script.wethFeeDistributor());
        assertEq(IPair(wbtc_usdc_pair).feeTo(), script.wbtcFeeDistributor());
        assertEq(IPair(dysn_usdc_pair).feeTo(), script.dysnFeeDistributor());
        assertEq(address(IPair(weth_usdc_pair).farm()), farm);
        assertEq(address(IPair(wbtc_usdc_pair).farm()), farm);
        assertEq(address(IPair(dysn_usdc_pair).farm()), farm);

        // pair balance check
        assertEq(USDC(usdc).balanceOf(weth_usdc_pair), WETHPAIR_USDC_LIQUIDITY);
        assertEq(WETH(weth).balanceOf(weth_usdc_pair), WETHPAIR_WETH_LIQUIDITY);
        assertEq(USDC(usdc).balanceOf(wbtc_usdc_pair), WBTCPAIR_USDC_LIQUIDITY);
        assertEq(WBTC(wbtc).balanceOf(wbtc_usdc_pair), WBTCPAIR_WBTC_LIQUIDITY);
        assertEq(USDC(usdc).balanceOf(dysn_usdc_pair), DYSNPAIR_USDC_LIQUIDITY);
        assertEq(IDYSON(dyson).balanceOf(dysn_usdc_pair), DYSNPAIR_DYSN_LIQUIDITY);

        (uint reserve0, uint reserve1) = IPair(weth_usdc_pair).getReserves();
        (uint expect0, uint expect1) = getExpectedReserves(weth, usdc, WETHPAIR_WETH_LIQUIDITY, WETHPAIR_USDC_LIQUIDITY);
        assertEq(reserve0, expect0);
        assertEq(reserve1, expect1);

        (reserve0, reserve1) = IPair(wbtc_usdc_pair).getReserves();
        (expect0, expect1) = getExpectedReserves(wbtc, usdc, WBTCPAIR_WBTC_LIQUIDITY, WBTCPAIR_USDC_LIQUIDITY);
        assertEq(reserve0, expect0);
        assertEq(reserve1, expect1);

        (reserve0, reserve1) = IPair(dysn_usdc_pair).getReserves();
        (expect0, expect1) = getExpectedReserves(dyson, usdc, DYSNPAIR_DYSN_LIQUIDITY, DYSNPAIR_USDC_LIQUIDITY);
        assertEq(reserve0, expect0);
        assertEq(reserve1, expect1);

        // sDyson params check
        assertEq(address(IsDYSON(sDyson).currentModel()), address(script.rateModel()));

        // Farm params check
        (uint weight,,,, address gauge) = IFarm(farm).pools(weth_usdc_pair);
        assertEq(gauge, address(wethGauge));
        assertEq(weight, WEIGHT_WETH);
        
        (weight,,,, gauge) = IFarm(farm).pools(wbtc_usdc_pair);
        assertEq(gauge, address(wbtcGauge));
        assertEq(weight, WEIGHT_WBTC);

        (weight,,,, gauge) = IFarm(farm).pools(dysn_usdc_pair);
        assertEq(gauge, address(dysonGauge));
        assertEq(weight, WEIGHT_DYSN);

        (uint globalWeight, uint globalRewardRate,,,) = IFarm(farm).globalPool();
        assertEq(globalWeight, GLOBALWEIGHT);
        assertEq(globalRewardRate, GLOBALRATE);

        // Faucet params check
        assertEq(address(Faucet(faucet).token0()), dyson);
        assertEq(address(Faucet(faucet).token1()), usdc);
        assertEq(address(Faucet(faucet).token2()), wbtc);
        assertEq(address(Faucet(faucet).agency()), agency);

        // AddressBook params check
        assertEq(AddressBook(addressBook).govToken(), dyson);
        assertEq(AddressBook(addressBook).govTokenStaking(), sDyson);
        assertEq(AddressBook(addressBook).factory(), factory);
        assertEq(AddressBook(addressBook).router(), router);
        assertEq(AddressBook(addressBook).farm(), farm);
        assertEq(AddressBook(addressBook).agentNFT(), IAgency(agency).agentNFT());
        assertEq(AddressBook(addressBook).agency(), agency);
        assertEq(AddressBook(addressBook).bribeOfGauge(address(dysonGauge)), address(dysonBribe));
        assertEq(AddressBook(addressBook).bribeOfGauge(address(wbtcGauge)), address(wbtcBribe));
        assertEq(AddressBook(addressBook).bribeOfGauge(address(wethGauge)), address(wethBribe));
        assertEq(AddressBook(addressBook).getCanonicalIdOfPair(weth, usdc), 1);
        assertEq(AddressBook(addressBook).getCanonicalIdOfPair(wbtc, usdc), 1);
        assertEq(AddressBook(addressBook).getCanonicalIdOfPair(dyson, usdc), 1);

        // Ownership check
        assertEq(IAgency(agency).owner(), owner);
        assertEq(IDYSON(dyson).owner(), owner);
        assertEq(USDC(usdc).owner(), owner);
        assertEq(WBTC(wbtc).owner(), owner);
        assertEq(IFarm(farm).owner(), owner);
        assertEq(IRouter(router).owner(), owner);
        assertEq(script.faucet().owner(), owner);
        assertEq(AddressBook(addressBook).owner(), owner);
        assertEq(IsDYSON(sDyson).owner(), owner);
        // After transferOwnership, Owner still need to claim ownership of factory by himself
        // assertEq(IFactory(factory).controller(), owner);

        // Allowance check
        assertEq(USDC(usdc).allowance(address(script.router()), weth_usdc_pair), type(uint).max);
        assertEq(WETH(weth).allowance(address(script.router()), weth_usdc_pair), type(uint).max);
        assertEq(USDC(usdc).allowance(address(script.router()), wbtc_usdc_pair), type(uint).max);
        assertEq(WBTC(wbtc).allowance(address(script.router()), wbtc_usdc_pair), type(uint).max);
        assertEq(USDC(usdc).allowance(address(script.router()), dysn_usdc_pair), type(uint).max);
        assertEq(IDYSON(dyson).allowance(address(script.router()), dysn_usdc_pair), type(uint).max);
        assertEq(IDYSON(dyson).allowance(address(script.router()), sDyson), type(uint).max);
        assertEq(IsDYSON(sDyson).allowance(address(script.router()), address(dysonGauge)), type(uint).max);
        assertEq(IsDYSON(sDyson).allowance(address(script.router()), address(wbtcGauge)), type(uint).max);
        assertEq(IsDYSON(sDyson).allowance(address(script.router()), address(wethGauge)), type(uint).max);
    }

    function testFaucet() public {
        vm.prank(alice);
        Faucet(faucet).claimToken();

        assertEq(USDC(usdc).balanceOf(alice), 25000e6);
        assertEq(IDYSON(dyson).balanceOf(alice), 10000e18);
        assertEq(WBTC(wbtc).balanceOf(alice), 1e8);
    }

    function getExpectedReserves(address tokenA, address tokenB, uint reserveA, uint reserveB) internal pure returns (uint reserve0, uint reserve1) {
        (reserve0, reserve1) = tokenA < tokenB ? (reserveA, reserveB) : (reserveB, reserveA);
    }
}
