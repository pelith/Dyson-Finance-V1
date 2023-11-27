// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../../script/MainnetDeployPart1.s.sol";
import "../../script/MainnetDeployPart2.s.sol";
import "../../script/TreasuryVesterDeploy.s.sol";
import "../../script/Addresses.sol";
import "../../script/Amounts.sol";
import "src/util/AddressBook.sol";
import "src/util/TreasuryVester.sol";
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
import "interface/IERC20.sol";
import "../TestUtils.sol";

contract MainnetDeployTest is Addresses, Amounts, TestUtils {
    MainnetDeployScriptPart1 script1;
    MainnetDeployScriptPart2 script2;
    TreasuryVesterDeployScript treasuryVesterScript;

    address owner = vm.envAddress("OWNER_ADDRESS");
    uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
    address deployer = vm.addr(deployerPrivateKey);
    address daoWallet = vm.envAddress("DAO_WALLET");

    address payable weth;
    address usdc;
    address dyson;
    address sDyson;
    address factory;
    address agency; 
    address farm;
    address addressBook;
    address router;
    IGauge dysonGauge;
    IBribe dysonBribe;
    IGauge wethGauge;
    IBribe wethBribe; 
    
    uint WEIGHT_DYSN;
    uint WEIGHT_WETH;
    uint BASE;
    uint SLOPE;
    uint GLOBALRATE;
    uint GLOBALWEIGHT;

    address weth_usdc_pair;
    address dysn_usdc_pair;

    address wethFeeDistributor;
    address dysnFeeDistributor;

    address[] treasuryVesters;
    address[] treasuryRecipients;
    uint[] treasuryAmounts;
    address[] sDysonRecipients;
    uint[] sDysonAmounts;

    function setUp() public {
        setupTreasuryRecipients();
        setupTreasuryAmounts();
        setupSDysonRecipients();
        setupSDysonAmounts();
        
        // start fork
        string memory rpcUrl = vm.rpcUrl("polygonZKEVM");
        vm.createSelectFork(rpcUrl);
        vm.deal(deployer, 100 ether);

        // Run part1 deploy script
        script1 = new MainnetDeployScriptPart1();
        script1.run();

        // Get address from part1 deploy script
        dyson = getAddress("DYSON");
        sDyson = getAddress("sDYSON");
        weth_usdc_pair = getAddress("wethUsdcPair");
        factory = getAddress("factory");
        addressBook = getAddress("addressBook");
        router = getAddress("router");
        vm.prank(owner);
        IFactory(factory).becomeController();

        // Owner must pre-config for part2 deploy script
        vm.startPrank(owner);
        AddressBook(addressBook).file("owner", deployer);
        IDYSON(dyson).transferOwnership(deployer);
        IsDYSON(sDyson).transferOwnership(deployer);
        IFactory(factory).setController(deployer);
        IRouter(router).transferOwnership(deployer);
        vm.stopPrank();

        // Run part2 deploy script
        script2 = new MainnetDeployScriptPart2();
        script2.run();
        // After deployment, owner must claim ownership of factory by himself
        vm.prank(owner);
        IFactory(factory).becomeController();

        // Run TreasuryVester deploy script
        treasuryVesterScript = new TreasuryVesterDeployScript();
        treasuryVesterScript.run();
        treasuryVesters.push(treasuryVesterScript.treasuryVesters(0));
        treasuryVesters.push(treasuryVesterScript.treasuryVesters(1));
        treasuryVesters.push(treasuryVesterScript.treasuryVesters(2));
        treasuryVesters.push(treasuryVesterScript.treasuryVesters(3));

        usdc = getOfficialAddress("USDC");
        weth = payable(getOfficialAddress("WETH"));
        
        dysn_usdc_pair = address(script2.dysn_usdc_pair());
        agency = address(script2.agency());
        farm = address(script2.farm());

        WEIGHT_DYSN = script2.WEIGHT_DYSN();
        WEIGHT_WETH = script2.WEIGHT_WETH();
        BASE = script2.BASE();
        SLOPE = script2.SLOPE();
        GLOBALRATE = script2.GLOBALRATE();
        GLOBALWEIGHT = script2.GLOBALWEIGHT();
        dysonGauge = IGauge(script2.dysonGauge());
        dysonBribe = IBribe(script2.dysonBribe());
        wethGauge = IGauge(script2.wethGauge());
        wethBribe = IBribe(script2.wethBribe());

        wethFeeDistributor = script2.wethFeeDistributor();
        dysnFeeDistributor = script2.dysnFeeDistributor();
    }

    function testContractSetup() public {
        // Router Params check
        assertEq(IRouter(router).WETH(), weth);
        assertEq(IRouter(router).sDYSON(), sDyson);
        assertEq(IRouter(router).DYSON(), dyson);
        assertEq(IRouter(router).DYSON_FACTORY(), factory);

        // Agency params check
        assertEq(IAgency(agency).whois(owner), 0); // check root agent = owner

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

        // FeeDistributor params check
        assertEq(IFeeDistributor(wethFeeDistributor).owner(), daoWallet);
        assertEq(IFeeDistributor(wethFeeDistributor).pair(), weth_usdc_pair);
        assertEq(IFeeDistributor(wethFeeDistributor).bribe(), address(wethBribe));
        assertEq(IFeeDistributor(wethFeeDistributor).daoWallet(), daoWallet);
        assertEq(IFeeDistributor(wethFeeDistributor).feeRateToDao(), script2.feeRateToDao());

        assertEq(IFeeDistributor(dysnFeeDistributor).owner(), daoWallet);
        assertEq(IFeeDistributor(dysnFeeDistributor).pair(), dysn_usdc_pair);
        assertEq(IFeeDistributor(dysnFeeDistributor).bribe(), address(dysonBribe));
        assertEq(IFeeDistributor(dysnFeeDistributor).daoWallet(), daoWallet);
        assertEq(IFeeDistributor(dysnFeeDistributor).feeRateToDao(), script2.feeRateToDao());

        // Minter check
        assertEq(IDYSON(dyson).isMinter(address(farm)), true);

        // Pair params check
        // assertEq(IPair(weth_usdc_pair).feeTo(), script2.wethFeeDistributor());
        // assertEq(IPair(dysn_usdc_pair).feeTo(), script2.dysnFeeDistributor());
        assertEq(address(IPair(weth_usdc_pair).farm()), farm);
        assertEq(address(IPair(dysn_usdc_pair).farm()), farm);

        // sDyson params check
        assertEq(address(IsDYSON(sDyson).currentModel()), address(script2.rateModel()));

        // Farm params check
        (uint weight,,,, address gauge) = IFarm(farm).pools(weth_usdc_pair);
        assertEq(gauge, address(wethGauge));
        assertEq(weight, WEIGHT_WETH);

        (weight,,,, gauge) = IFarm(farm).pools(dysn_usdc_pair);
        assertEq(gauge, address(dysonGauge));
        assertEq(weight, WEIGHT_DYSN);

        // AddressBook params check
        assertEq(AddressBook(addressBook).govToken(), dyson);
        assertEq(AddressBook(addressBook).govTokenStaking(), sDyson);
        assertEq(AddressBook(addressBook).factory(), factory);
        assertEq(AddressBook(addressBook).router(), router);
        assertEq(AddressBook(addressBook).farm(), farm);
        assertEq(AddressBook(addressBook).agentNFT(), IAgency(agency).agentNFT());
        assertEq(AddressBook(addressBook).agency(), agency);
        assertEq(AddressBook(addressBook).bribeOfGauge(address(dysonGauge)), address(dysonBribe));
        assertEq(AddressBook(addressBook).bribeOfGauge(address(wethGauge)), address(wethBribe));
        assertEq(AddressBook(addressBook).getCanonicalIdOfPair(weth, usdc), 1);
        assertEq(AddressBook(addressBook).getCanonicalIdOfPair(dyson, usdc), 1);

        // Ownership check
        assertEq(IAgency(agency).owner(), owner);
        assertEq(IDYSON(dyson).owner(), owner);
        assertEq(IFarm(farm).owner(), owner);
        assertEq(IRouter(router).owner(), owner);
        assertEq(AddressBook(addressBook).owner(), owner);
        assertEq(IsDYSON(sDyson).owner(), owner);
        assertEq(IFactory(factory).controller(), owner);

        // Allowance check
        assertEq(IERC20(usdc).allowance(address(script2.router()), weth_usdc_pair), type(uint).max);
        assertEq(IERC20(weth).allowance(address(script2.router()), weth_usdc_pair), type(uint).max);
        assertEq(IERC20(usdc).allowance(address(script2.router()), dysn_usdc_pair), type(uint).max);
        assertEq(IERC20(dyson).allowance(address(script2.router()), dysn_usdc_pair), type(uint).max);
        assertEq(IERC20(dyson).allowance(address(script2.router()), sDyson), type(uint).max);
        assertEq(IERC20(sDyson).allowance(address(script2.router()), address(dysonGauge)), type(uint).max);
        assertEq(IERC20(sDyson).allowance(address(script2.router()), address(wethGauge)), type(uint).max);

        // TreasuryVester params check
        for (uint i; i < treasuryVesters.length - 1; ++i) {
            address recipient = treasuryRecipients[i];
            uint amount = treasuryAmounts[i];
            TreasuryVester vester = TreasuryVester(treasuryVesters[i]);
            assertEq(vester.token(), dyson);
            assertEq(vester.recipient(), recipient);
            assertEq(vester.vestingAmount(), amount);
            assertEq(vester.vestingBegin(), treasuryVesterScript.vestingBegin());
            assertEq(vester.vestingCliff(), treasuryVesterScript.vestingCliff());
            assertEq(vester.vestingEnd(), treasuryVesterScript.vestingEnd());
        }

        TreasuryVester ecoVester = TreasuryVester(treasuryVesters[treasuryVesters.length - 1]);
        assertEq(ecoVester.token(), dyson);
        assertEq(ecoVester.recipient(), daoWallet);
        assertEq(ecoVester.vestingAmount(), treasuryVesterScript.ecosystemVestingAmount());
        assertEq(ecoVester.vestingBegin(), treasuryVesterScript.ecosystemVestingBegin());
        assertEq(ecoVester.vestingCliff(), treasuryVesterScript.ecosystemVestingCliff());
        assertEq(ecoVester.vestingEnd(), treasuryVesterScript.ecosystemVestingEnd());

        
        for (uint i; i < sDysonRecipients.length; ++i) {
            assertEq(IsDYSON(sDyson).dysonAmountStaked(sDysonRecipients[i]), sDysonAmounts[i]);
        }
    }

    function setupTreasuryAmounts() internal {
        treasuryAmounts = [100e18, 200e18, 300e18];
        string memory amountsObj = '["100","200","300"]';
        vm.writeJson(amountsObj, "deploy-config.json", ".TreasuryAmounts");
    }

    function setupTreasuryRecipients() internal {
        treasuryRecipients = [
            0x0000000000000000000000000000000000000111,
            0x0000000000000000000000000000000000000222,
            0x0000000000000000000000000000000000000333
        ];
        string memory recipientObj = '["0x0000000000000000000000000000000000000111","0x0000000000000000000000000000000000000222","0x0000000000000000000000000000000000000333"]';
        vm.writeJson(recipientObj, "deploy-config.json", ".TreasuryRecipients");

    }

    function setupSDysonRecipients() internal {
        sDysonRecipients = [
            0x0000000000000000000000000000000000000444,
            0x0000000000000000000000000000000000000555,
            0x0000000000000000000000000000000000000666
        ];
        string memory sDysonRecipientObj = '["0x0000000000000000000000000000000000000444","0x0000000000000000000000000000000000000555","0x0000000000000000000000000000000000000666"]';
        vm.writeJson(sDysonRecipientObj, "deploy-config.json", ".sDYSONRecipients");
    }

    function setupSDysonAmounts() internal {
        sDysonAmounts = [400e18, 500e18, 600e18];
        string memory sDysonAmountsObj = '["400","500","600"]';
        vm.writeJson(sDysonAmountsObj, "deploy-config.json", ".sDYSONAmounts");
    }
}