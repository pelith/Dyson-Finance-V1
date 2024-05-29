pragma solidity 0.8.17;

// SPDX-License-Identifier: AGPL-3.0-only
import "interface/IPair.sol";
import "interface/IFactory.sol";
import "forge-std/console.sol";
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

    event PairCreated(address indexed factoryAddress, address indexed tokenA, address indexed tokenB, address pair);
    event PairBasisSet(address indexed pair, uint basis);
    event PairHalfLifeSet(address indexed pair, uint64 halfLife);
    event PairFarmSet(address indexed pair, address farm);
    event PairFeeToSet(address indexed pair, address feeTo);

    constructor() Ownable(){
    }

    function changeAdmin(address newAdmin) external onlyOwner {
        transferOwnership(newAdmin);
    }

    function updateValidateRule(address pair, string memory name, uint256 lowerBound, uint256 upperBound) public onlyOwner {
        require(lowerBound < upperBound, "Invalid rule bounds");
        require(lowerBound > 0, "Basis & HalfLife value must be positive");
        validators[pair][name] = ValidationRule(lowerBound, upperBound);
    }
    
    function validateValue(address pair, string memory name, uint256 value) public view returns (bool) {
        ValidationRule memory rule = validators[pair][name];
        return (value >= rule.lowerBound && value <= rule.upperBound);
    }

    function addRole(address contractAddr, address operator, bytes4 functionSelector) external onlyOwner{
        bytes32 role = keccak256(abi.encodePacked(contractAddr, operator, functionSelector));
        _permission[role] = true;
    }

    function removeRole(address contractAddr, address operator, bytes4 functionSelector) external onlyOwner {
        bytes32 role = keccak256(abi.encodePacked(contractAddr, operator, functionSelector));
        delete _permission[role];
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

    function createPair(address factoryAddress, address tokenA, address tokenB) external returns (address pair){
        require(msg.sender == owner() || hasRole(factoryAddress, msg.sender, Factory.createPair.selector), "forbidden");
        pair = IFactory(factoryAddress).createPair(tokenA, tokenB);
        emit PairCreated(factoryAddress, tokenA, tokenB, pair);
    }

    function setPairBasis(address pair, uint basis) external{
        require(msg.sender == owner() || hasRole(pair, msg.sender, Pair.setBasis.selector), "forbidden");
        require(validateValue(pair, "basis", basis), "Invalid basis value");
        IPair(pair).setBasis(basis);
        emit PairBasisSet(pair, basis);
    }

    function setPairHalfLife(address pair, uint64 halfLife) external{
        require(msg.sender == owner() || hasRole(pair, msg.sender, Pair.setHalfLife.selector), "forbidden");
        require(validateValue(pair, "halfLife", halfLife), "Invalid halfLife value");
        IPair(pair).setHalfLife(halfLife);
        emit PairHalfLifeSet(pair, halfLife);
    }

    function setPairFarm(address pair, address farm) external{
        require(msg.sender == owner() || hasRole(pair, msg.sender, Pair.setFarm.selector), "forbidden");
        IPair(pair).setFarm(farm);
        emit PairFarmSet(pair, farm);
    }

    function setPairFeeTo(address pair, address feeTo) external{
        require(msg.sender == owner() || hasRole(pair, msg.sender, Pair.setFeeTo.selector), "forbidden");
        IPair(pair).setFeeTo(feeTo);
        emit PairFeeToSet(pair, feeTo);
    }
}