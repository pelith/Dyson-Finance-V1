pragma solidity 0.8.17;

// SPDX-License-Identifier: AGPL-3.0-only
import "interface/IPair.sol";
import "interface/IFactory.sol";
import "./Factory.sol";
import "./Pair.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AdminPanel is Ownable {

    mapping(bytes32 => bool) private _permission;

    struct ValidationRule {
        uint256 lowerBound;
        uint256 upperBound;
    }
    mapping(address => mapping(string => ValidationRule)) public validators;

    event OwnerChanged(address indexed oldAdmin, address indexed newAdmin);
    event RoleAdded(address indexed contractAddr, address indexed operator, bytes4 indexed functionSelector);
    event RoleRemoved(address indexed contractAddr, address indexed operator, bytes4 indexed functionSelector);
    event ValidateRuleUpdated(address indexed pair, string name, uint256 lowerBound, uint256 upperBound);
    event PairCreated(address indexed factoryAddress, address indexed tokenA, address indexed tokenB, address pair, address sender);
    event PairBasisSet(address indexed pair, uint basis, address sender);
    event PairHalfLifeSet(address indexed pair, uint64 halfLife, address sender);
    event PairFarmSet(address indexed pair, address farm, address sender);
    event PairFeeToSet(address indexed pair, address feeTo, address sender);

    constructor() Ownable(){
    }

    function changeOwner(address newAdmin) external onlyOwner {
        transferOwnership(newAdmin);
        emit OwnerChanged(msg.sender, newAdmin);
    }

    function updateValidateRule(address pair, string memory name, uint256 lowerBound, uint256 upperBound) public onlyOwner {
        require(lowerBound < upperBound, "Invalid rule bounds");
        require(lowerBound > 0, "Basis & HalfLife value must be positive");
        validators[pair][name] = ValidationRule(lowerBound, upperBound);
        emit ValidateRuleUpdated(pair, name, lowerBound, upperBound);
    }
    
    function validateValue(address pair, string memory name, uint256 value) public view returns (bool) {
        ValidationRule memory rule = validators[pair][name];
        return (value >= rule.lowerBound && value <= rule.upperBound);
    }

    function addRole(address contractAddr, address operator, bytes4 functionSelector) external onlyOwner {
        bytes32 role = keccak256(abi.encodePacked(contractAddr, operator, functionSelector));
        _permission[role] = true;
        emit RoleAdded(contractAddr, operator, functionSelector);
    }

    function removeRole(address contractAddr, address operator, bytes4 functionSelector) external onlyOwner {
        bytes32 role = keccak256(abi.encodePacked(contractAddr, operator, functionSelector));
        delete _permission[role];
        emit RoleRemoved(contractAddr, operator, functionSelector);
    }

    function hasRole(address contractAddr, address operator, bytes4 functionSelector) public view returns (bool) {
        bytes32 role = keccak256(abi.encodePacked(contractAddr, operator, functionSelector));
        return _permission[role];
    }

    function becomeFactoryController(address factoryAddress) external onlyOwner {
        IFactory(factoryAddress).becomeController();
    }

    function setFactoryController(address factoryAddress, address newController) external onlyOwner {
        IFactory(factoryAddress).setController(newController);
    }

    function createPair(address factoryAddress, address tokenA, address tokenB) external returns (address pair) {
        require(hasRole(factoryAddress, msg.sender, Factory.createPair.selector) || msg.sender == owner(), "forbidden");
        pair = IFactory(factoryAddress).createPair(tokenA, tokenB);
        emit PairCreated(factoryAddress, tokenA, tokenB, pair, msg.sender);
    }

    function setPairBasis(address pair, uint basis) external {
        require(hasRole(pair, msg.sender, Pair.setBasis.selector) || msg.sender == owner(), "forbidden");
        require(validateValue(pair, "basis", basis), "Invalid basis value");
        IPair(pair).setBasis(basis);
        emit PairBasisSet(pair, basis, msg.sender);
    }

    function setPairHalfLife(address pair, uint64 halfLife) external {
        require(hasRole(pair, msg.sender, Pair.setHalfLife.selector) || msg.sender == owner(), "forbidden");
        require(validateValue(pair, "halfLife", halfLife), "Invalid halfLife value");
        IPair(pair).setHalfLife(halfLife);
        emit PairHalfLifeSet(pair, halfLife, msg.sender);
    }

    function setPairFarm(address pair, address farm) external {
        require(hasRole(pair, msg.sender, Pair.setFarm.selector) || msg.sender == owner(), "forbidden");
        IPair(pair).setFarm(farm);
        emit PairFarmSet(pair, farm, msg.sender);
    }

    function setPairFeeTo(address pair, address feeTo) external {
        require(hasRole(pair, msg.sender, Pair.setFeeTo.selector) || msg.sender == owner(), "forbidden");
        IPair(pair).setFeeTo(feeTo);
        emit PairFeeToSet(pair, feeTo, msg.sender);
    }
}