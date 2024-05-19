pragma solidity 0.8.17;

// SPDX-License-Identifier: AGPL-3.0-only
import "interface/IPair.sol";
import "interface/IFactory.sol";
import "forge-std/console.sol";

contract AdminPanel {

    address public admin;
    uint private unlocked = 1;
    mapping(bytes32 => bool) public permission;

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

    //The contractAddr can be the pair address or factory address
    modifier hasRole(address contractAddr, address operator, bytes4 functionSelector) {
        bytes32 role = keccak256(abi.encodePacked(contractAddr, operator, functionSelector));
        require(msg.sender == admin || permission[role] == true, "forbidden");
        _;
    }    

    function changeAdmin(address newAdmin) external onlyAdmin {
        admin = newAdmin;
    }

    function addRole(address contractAddr, address operator, bytes4 functionSelector) external onlyAdmin{
        bytes32 role = keccak256(abi.encodePacked(contractAddr, operator, functionSelector));
        permission[role] = true;
    }

    function removeRole(address contractAddr, address operator, bytes4 functionSelector) external onlyAdmin {
        bytes32 role = keccak256(abi.encodePacked(contractAddr, operator, functionSelector));
        delete permission[role];
    }

    function becomeFactoryController(address factoryAddress) external onlyAdmin {
        IFactory(factoryAddress).becomeController();
    }

    function createPair(address factoryAddress, address tokenA, address tokenB) external lock hasRole(factoryAddress, msg.sender, this.createPair.selector) returns (address pair){
        address pairAddr = IFactory(factoryAddress).createPair(tokenA, tokenB);
        return pairAddr;
    }

    function setPairBasis(address pair, uint basis) external lock hasRole(pair, msg.sender, this.setPairBasis.selector){
        IPair(pair).setBasis(basis);
    }

    function setPairHalfLife(address pair, uint64 halfLife) external lock hasRole(pair, msg.sender, this.setPairHalfLife.selector) {
        IPair(pair).setHalfLife(halfLife);
    }

    function setPairFarm(address pair, address farm) external lock hasRole(pair, msg.sender, this.setPairFarm.selector){
        IPair(pair).setFarm(farm);
    }

    function setPairFeeTo(address pair, address feeTo) external lock hasRole(pair, msg.sender, this.setPairFeeTo.selector){
        IPair(pair).setFeeTo(feeTo);
    }
}