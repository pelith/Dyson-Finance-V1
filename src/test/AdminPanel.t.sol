// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "ds-test/test.sol";
import "../AdminPanel.sol";
import "./TestUtils.sol";

contract AdminPanelTest is TestUtils {
    AdminPanel adminPanel;
    address testOwner = address(this);
    address alice = _nameToAddr("alice");
    address pair = address(0x123);

    function setUp() public {
        vm.prank(testOwner);
        adminPanel = new AdminPanel();
    }

    function testChangeAdmin() public {
        adminPanel.changeAdmin(alice);
        assertEq(adminPanel.admin(), alice);
    }

    function testAddPermission() public {
        adminPanel.addRolePermission(AdminPanel.Role.DEVELOPER, AdminPanel.setPairBasis.selector);
        assertTrue(adminPanel.rolePermissions(AdminPanel.Role.DEVELOPER, AdminPanel.setPairBasis.selector));
    }
}