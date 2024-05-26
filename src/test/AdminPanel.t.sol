// AdminPanel.t.sol
pragma solidity 0.8.17;

import "forge-std/console.sol";
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

        adminPanel.updateValidateRule("basis", 0.1e18, 1e18); // 0.1~1 volitility
        adminPanel.updateValidateRule("halfLife", 1, 1440); // 24 mins
    }

    function testChangeAdmin() public {
        adminPanel.changeAdmin(newAdmin);
        assertEq(adminPanel.admin(), newAdmin);
    }

    function testAddRole() public {
        bytes4 functionSelector = Factory.createPair.selector;
        bytes32 role = keccak256(abi.encodePacked(address(factory), alice , functionSelector));
        assertEq(adminPanel.permission(role), false);
        adminPanel.addRole(address(factory), alice, functionSelector);
        assertEq(adminPanel.permission(role), true);
    }

    function testRemoveRole() public {
        bytes4 functionSelector = Factory.createPair.selector;
        bytes32 role = keccak256(abi.encodePacked(address(factory), alice , functionSelector));
        adminPanel.addRole(address(factory), alice, functionSelector);
        assertEq(adminPanel.permission(role), true);
        adminPanel.removeRole(address(factory), alice, functionSelector);
        assertEq(adminPanel.permission(role), false);
    }

    function testAdminPanelCreatePair() public {
        bytes4 functionSelector = Factory.createPair.selector;
        bytes32 role = keccak256(abi.encodePacked(address(factory), alice , functionSelector));
        adminPanel.addRole(address(factory), alice, functionSelector);
        assertEq(adminPanel.permission(role), true);

        vm.prank(bob);
        vm.expectRevert("forbidden");
        adminPanel.createPair(address(factory),token0, token1);

        vm.prank(alice);
        adminPanel.createPair(address(factory),token0, token1);
        assertEq(factory.allPairsLength(), 2);
    }

    function testSetPairBasis() public {
        bytes4 functionSelector = Pair.setBasis.selector;
        bytes32 role = keccak256(abi.encodePacked(address(pair), alice , functionSelector));
        adminPanel.addRole(address(pair), alice, functionSelector);
        assertEq(adminPanel.permission(role), true);

        uint basis = 0;
        vm.prank(bob);
        vm.expectRevert("forbidden");
        adminPanel.setPairBasis(address(pair), basis);

        vm.prank(alice);
        vm.expectRevert("Invalid basis value");
        adminPanel.setPairBasis(address(pair), basis);

        basis = 0.5e18;
        bool isValid = adminPanel.validateValue("basis", basis);
        assertTrue(isValid);
        adminPanel.setPairBasis(address(pair), basis);
        assertEq(pair.basis(), basis);
    }

    function testSetPairHalfLife() public {
        bytes4 functionSelector = Pair.setHalfLife.selector;
        bytes32 role = keccak256(abi.encodePacked(address(pair), alice , functionSelector));
        adminPanel.addRole(address(pair), alice, functionSelector);
        assertEq(adminPanel.permission(role), true);

        uint64 halfLife = 1441;
        vm.prank(bob);
        vm.expectRevert("forbidden");
        adminPanel.setPairHalfLife(address(pair), halfLife);

        vm.prank(alice);
        vm.expectRevert("Invalid halfLife value");
        adminPanel.setPairHalfLife(address(pair), halfLife);

        halfLife = 720;
        bool isValid = adminPanel.validateValue("halfLife", halfLife);
        assertTrue(isValid);
        adminPanel.setPairHalfLife(address(pair), halfLife);
        assertEq(pair.halfLife(), halfLife);
    }

    function testSetPairFarm() public {
        bytes4 functionSelector = Pair.setFarm.selector;
        bytes32 role = keccak256(abi.encodePacked(address(pair), alice , functionSelector));
        adminPanel.addRole(address(pair), alice, functionSelector);
        assertEq(adminPanel.permission(role), true);

        vm.prank(bob);
        vm.expectRevert("forbidden");
        adminPanel.setPairFarm(address(pair), address(0x123));

        vm.prank(alice);
        adminPanel.setPairFarm(address(pair), address(0x123));
        assertEq(address(pair.farm()), address(0x123));
    }

    function testSetPairFeeTo() public {
        bytes4 functionSelector = Pair.setFeeTo.selector;
        bytes32 role = keccak256(abi.encodePacked(address(pair), alice , functionSelector));
        adminPanel.addRole(address(pair), alice, functionSelector);
        assertEq(adminPanel.permission(role), true);

        vm.prank(bob);
        vm.expectRevert("forbidden");
        adminPanel.setPairFeeTo(address(pair), address(0x123));

        vm.prank(alice);
        adminPanel.setPairFeeTo(address(pair), address(0x123));
        assertEq(pair.feeTo(), address(0x123));
    }


    function testSetPairHalfLifeForValidator() public {
        uint64 halfLife = 600;
        bool isValid = adminPanel.validateValue("halfLife", halfLife);
        assertTrue(isValid);
    }
}