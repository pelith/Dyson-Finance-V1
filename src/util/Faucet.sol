pragma solidity 0.8.17;

// SPDX-License-Identifier: AGPL-3.0

import "interface/IAgency.sol";

interface token {
    function mint(address to, uint amount) external returns (bool);
}

contract Faucet {
    address public owner;
    token public token0;
    token public token1;
    token public token2;
    IAgency public agency;
    uint constant amount0 = 10000e18; //DYSN
    uint constant amount1 = 25000e6; //USDC
    uint constant amount2 = 1e8; //WBTC

    mapping(address => bool) public tokenClaimed;
    mapping(address => bool) public agentClaimed;

    modifier onlyOwner() {
        require(msg.sender == owner, "FORBIDDEN");
        _;
    }

    constructor(address _owner) {
        owner = _owner;
    }

    function transferOwnership(address _owner) external onlyOwner {
        owner = _owner;
    }

    function set(address _token0, address _token1, address _token2, address _agency) external onlyOwner {
        token0 = token(_token0);
        token1 = token(_token1);
        token2 = token(_token2);
        agency = IAgency(_agency);
    }

    function claimToken() external {
        require(!tokenClaimed[msg.sender]);
        tokenClaimed[msg.sender] = true;
        token0.mint(msg.sender, amount0);
        token1.mint(msg.sender, amount1);
        token2.mint(msg.sender, amount2);
    }

    function claimAgent() external {
        require(!agentClaimed[msg.sender]);
        agentClaimed[msg.sender] = true;
        agency.adminAdd(msg.sender);
    }

}