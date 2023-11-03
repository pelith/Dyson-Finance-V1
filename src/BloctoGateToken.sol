pragma solidity 0.8.17;

import "interface/IERC20.sol";

contract BloctoGateToken is IERC20 {
	uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "Blocto Dyson Gate Token";
    string public symbol = "BLTGATE";
    uint8 public decimals = 0;

	address public owner;
	mapping(address => bool) public isMinter;

	constructor(address _owner) {
		owner = _owner;
	}

	modifier onlyOwner() {
        require(msg.sender == owner, "forbidden");
        _;
    }

	function addMinter(address _minter) external onlyOwner {
        isMinter[_minter] = true;
    }

    function removeMinter(address _minter) external onlyOwner {
        isMinter[_minter] = false;
    }

    function transfer(address, uint) external pure override returns (bool) {
        return false;
    }

    function approve(address, uint) external pure override returns (bool) {
        return false;
    }

    function transferFrom(
        address,
        address,
        uint
    ) external pure returns (bool) {
        return false;
    }

    function mint(uint amount) external {
		require(isMinter[msg.sender], 'forbidden');
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function burn(uint amount) external {
		require(isMinter[msg.sender], 'forbidden');
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}