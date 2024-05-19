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
        bytes4 functionSelector = AdminPanel.createPair.selector;
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
        bytes4 functionSelector = AdminPanel.setPairBasis.selector;
        bytes32 role = keccak256(abi.encodePacked(address(pair), alice , functionSelector));
        adminPanel.addRole(address(pair), alice, functionSelector);
        assertEq(adminPanel.permission(role), true);

        vm.prank(bob);
        vm.expectRevert("forbidden");
        adminPanel.setPairBasis(address(pair), 100);

        vm.prank(alice);
        adminPanel.setPairBasis(address(pair), 100);
        assertEq(pair.basis(), 100);
    }

    function testSetPairHalfLife() public {
        bytes4 functionSelector = AdminPanel.setPairHalfLife.selector;
        bytes32 role = keccak256(abi.encodePacked(address(pair), alice , functionSelector));
        adminPanel.addRole(address(pair), alice, functionSelector);
        assertEq(adminPanel.permission(role), true);

        vm.prank(bob);
        vm.expectRevert("forbidden");
        adminPanel.setPairHalfLife(address(pair), 100);

        vm.prank(alice);
        adminPanel.setPairHalfLife(address(pair), 100);
        assertEq(pair.halfLife(), 100);
    }

    function testSetPairFarm() public {
        bytes4 functionSelector = AdminPanel.setPairFarm.selector;
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
        bytes4 functionSelector = AdminPanel.setPairFeeTo.selector;
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
}