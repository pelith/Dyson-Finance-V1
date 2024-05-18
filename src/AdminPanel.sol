pragma solidity 0.8.17;

// SPDX-License-Identifier: AGPL-3.0-only
import "interface/IPair.sol";

contract AdminPanel {

    address public admin;
    uint private unlocked = 1;
    //pair address => operator address => role level
    mapping(address => mapping(address => Role)) public operatorRoles;
    mapping(Role => mapping(bytes4 => bool)) public rolePermissions;

    enum Role { 
        VIEWER,
        DEVELOPER, 
        ADMIN 
    }

    constructor() {
        admin = msg.sender;
    }

    modifier lock() {
        require(unlocked == 1, 'locked');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "forbidden");
        _;
    }

    function changeAdmin(address newAdmin) external onlyAdmin {
        admin = newAdmin;
    }

    function addRolePermission(Role role, bytes4 functionSelector) public {
        require(msg.sender == admin, "forbidden");
        rolePermissions[role][functionSelector] = true;
    }

    function removeRolePermission(Role role, bytes4 functionSelector) public {
        require(msg.sender == admin, "forbidden");
        delete rolePermissions[role][functionSelector];
    }

    function addRole(address pair, address operator, Role role) public {
        require(msg.sender == admin, "forbidden");
        operatorRoles[pair][operator] = role;
    }

    function removeRole(address pair, address operator) public {
        require(msg.sender == admin, "forbidden");
        delete operatorRoles[pair][operator];
    }

    function setPairBasis(address pair, uint basis) external lock {
        require(msg.sender == admin || _hasRole(pair, msg.sender, this.setPairBasis.selector), "forbidden");
        IPair(pair).setBasis(basis);
    }

    function setPairHalfLife(address pair, uint64 halfLife) external lock {
        require(msg.sender == admin || _hasRole(pair, msg.sender, this.setPairHalfLife.selector), "forbidden");
        IPair(pair).setHalfLife(halfLife);
    }

    function setPairFarm(address pair, address farm) external lock {
        require(msg.sender == admin || _hasRole(pair, msg.sender, this.setPairFarm.selector), "forbidden");
        IPair(pair).setFarm(farm);
    }

    function setPairFeeTo(address pair, address feeTo) external lock {
        require(msg.sender == admin || _hasRole(pair, msg.sender, this.setPairFeeTo.selector), "forbidden");
        IPair(pair).setFeeTo(feeTo);
    }

    function _hasRole(address pair, address operator, bytes4 functionSelector) private view returns (bool) {
        Role role = operatorRoles[pair][operator];
        return rolePermissions[role][functionSelector];
    }
}