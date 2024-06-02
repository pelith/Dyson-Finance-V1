// AdminPanel.t.sol
pragma solidity 0.8.17;

import "src/Pair.sol";
import "src/Factory.sol";
import "src/DYSON.sol";
import "../AdminPanel.sol";
import "./TestUtils.sol";

contract AdminPanelTest is TestUtils {
    AdminPanel adminPanel;
    Factory factory;

    address testAdmin = address(this);
    address newAdmin = _nameToAddr("newAdmin");
    address alice = _nameToAddr("alice");
    address bob = _nameToAddr("bob");

    address token0 = address(new DYSON(testAdmin));
    address token1 = address(new DYSON(testAdmin));
    Pair pair;

    function setUp() public {
        adminPanel = new AdminPanel();
        factory = new Factory(address(testAdmin));

        assertEq(factory.controller(), address(testAdmin));
        factory.setController(address(adminPanel));
        adminPanel.becomeFactoryController(address(factory));
        assertEq(factory.controller(), address(adminPanel));

        pair = Pair(adminPanel.createPair(address(factory), token0, token1));

        adminPanel.updateValidateRule(address(pair), "basis", 0.1e18, 1e18); // 0.1~1 volitility
        adminPanel.updateValidateRule(address(pair), "halfLife", 1, 1440); // 24 mins
    }

    function testChangeOwner() public {
        adminPanel.changeOwner(newAdmin);
        assertEq(adminPanel.owner(), newAdmin);
    }

    function testAddRole() public {
        bytes4 functionSelector = Factory.createPair.selector;
        assertEq(adminPanel.hasRole(address(factory), alice , functionSelector), false);
        adminPanel.addRole(address(factory), alice, functionSelector);
        assertEq(adminPanel.hasRole(address(factory), alice , functionSelector), true);
    }

    function testRemoveRole() public {
        bytes4 functionSelector = Factory.createPair.selector;
        adminPanel.addRole(address(factory), alice, functionSelector);
        assertEq(adminPanel.hasRole(address(factory), alice , functionSelector), true);
        adminPanel.removeRole(address(factory), alice, functionSelector);
        assertEq(adminPanel.hasRole(address(factory), alice , functionSelector), false);
    }

    function testAdminPanelCreatePair() public {
        bytes4 functionSelector = Factory.createPair.selector;
        adminPanel.addRole(address(factory), alice, functionSelector);

        vm.prank(bob);
        vm.expectRevert("forbidden");
        adminPanel.createPair(address(factory),token0, token1);

        vm.prank(alice);
        adminPanel.createPair(address(factory),token0, token1);
        assertEq(factory.allPairsLength(), 2);
    }

    function testSetPairBasis() public {
        bytes4 functionSelector = Pair.setBasis.selector;
        adminPanel.addRole(address(pair), alice, functionSelector);

        uint basis = 0;
        vm.prank(bob);
        vm.expectRevert("forbidden");
        adminPanel.setPairBasis(address(pair), basis);

        vm.prank(alice);
        vm.expectRevert("Invalid basis value");
        adminPanel.setPairBasis(address(pair), basis);

        basis = 0.5e18;
        bool isValid = adminPanel.validateValue(address(pair), "basis", basis);
        assertTrue(isValid);
        adminPanel.setPairBasis(address(pair), basis);
        assertEq(pair.basis(), basis);
    }

    function testSetPairHalfLife() public {
        bytes4 functionSelector = Pair.setHalfLife.selector;
        adminPanel.addRole(address(pair), alice, functionSelector);

        uint64 halfLife = 1441;
        vm.prank(bob);
        vm.expectRevert("forbidden");
        adminPanel.setPairHalfLife(address(pair), halfLife);

        vm.prank(alice);
        vm.expectRevert("Invalid halfLife value");
        adminPanel.setPairHalfLife(address(pair), halfLife);

        halfLife = 720;
        bool isValid = adminPanel.validateValue(address(pair), "halfLife", halfLife);
        assertTrue(isValid);
        adminPanel.setPairHalfLife(address(pair), halfLife);
        assertEq(pair.halfLife(), halfLife);
    }

    function testSetPairFarm() public {
        bytes4 functionSelector = Pair.setFarm.selector;
        adminPanel.addRole(address(pair), alice, functionSelector);

        vm.prank(bob);
        vm.expectRevert("forbidden");
        adminPanel.setPairFarm(address(pair), address(0x123));

        vm.prank(alice);
        adminPanel.setPairFarm(address(pair), address(0x123));
        assertEq(address(pair.farm()), address(0x123));
    }

    function testSetPairFeeTo() public {
        bytes4 functionSelector = Pair.setFeeTo.selector;
        adminPanel.addRole(address(pair), alice, functionSelector);

        vm.prank(bob);
        vm.expectRevert("forbidden");
        adminPanel.setPairFeeTo(address(pair), address(0x123));

        vm.prank(alice);
        adminPanel.setPairFeeTo(address(pair), address(0x123));
        assertEq(pair.feeTo(), address(0x123));
    }
}