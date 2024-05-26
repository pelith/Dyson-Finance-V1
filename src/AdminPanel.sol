pragma solidity 0.8.17;

// SPDX-License-Identifier: AGPL-3.0-only
import "interface/IPair.sol";
import "interface/IFactory.sol";
import "forge-std/console.sol";
import "./Factory.sol";
import "./Pair.sol";

contract AdminPanel {

    address public admin;
    uint private unlocked = 1;
    mapping(bytes32 => bool) public permission;

    struct ValidationRule {
        uint256 lowerBound;
        uint256 upperBound;
    }
    mapping(string => ValidationRule) public validators;

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

    function updateValidateRule(string memory name, uint256 lowerBound, uint256 upperBound) public onlyAdmin {
        require(lowerBound <= upperBound, "Invalid rule bounds");
        validators[name] = ValidationRule(lowerBound, upperBound);
    }
    
    function validateValue(string memory name, uint256 value) public view returns (bool) {
        ValidationRule memory rule = validators[name];
        require(rule.lowerBound > 0 || rule.upperBound > 0, "Validation rule does not exist");
        return (value >= rule.lowerBound && value <= rule.upperBound);
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

    function setFactoryController(address factoryAddress, address newController) external onlyAdmin {
        IFactory(factoryAddress).setController(newController);
    }

    function createPair(address factoryAddress, address tokenA, address tokenB) external lock hasRole(factoryAddress, msg.sender, Factory.createPair.selector) returns (address pair){
        address pairAddr = IFactory(factoryAddress).createPair(tokenA, tokenB);
        return pairAddr;
    }

    function setPairBasis(address pair, uint basis) external lock hasRole(pair, msg.sender, Pair.setBasis.selector){
        require(validateValue("basis", basis), "Invalid basis value");
        IPair(pair).setBasis(basis);
    }

    function setPairHalfLife(address pair, uint64 halfLife) external lock hasRole(pair, msg.sender, Pair.setHalfLife.selector) {
        require(validateValue("halfLife", halfLife), "Invalid halfLife value");
        IPair(pair).setHalfLife(halfLife);
    }

    function setPairFarm(address pair, address farm) external lock hasRole(pair, msg.sender, Pair.setFarm.selector){
        IPair(pair).setFarm(farm);
    }

    function setPairFeeTo(address pair, address feeTo) external lock hasRole(pair, msg.sender, Pair.setFeeTo.selector){
        IPair(pair).setFeeTo(feeTo);
    }
}