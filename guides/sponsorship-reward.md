# Sponsorship Reward

## As a sponsor who gives reward

Dyson Finance supports Sponsorship feature, which allows everyone including DAO to add sponsored tokens in specific Gauge to attract more voters. A sponsor needs to specify the sponsored token, the amount of token and the number of week since Epoch. Explore the [Sponsorship](https://docs.dyson.finance/mechanisms/gauge-and-yield-boosting#sponsorship) section in our white paper for further insights into sponsorship.

```solidity
// Bribe.sol
function addReward(address token, uint week, uint amount) external {
    require(week >= block.timestamp / 1 weeks, "cannot add for previous weeks");
    token.safeTransferFrom(msg.sender, address(this), amount);
    tokenRewardOfWeek[token][week] += amount;
    emit AddReward(msg.sender, token, week, amount);
}
```

Parameters:

* `token`: Address of the token to add as reward
* `week`: The week to add the reward to. It's the i-th week since 1970/01/01 and it must be the present week or a week in the future.
* `amount` : Amount of token.

**Set Up your Contract**

For example, a sponsor want to sponsor $MATIC as reward on the target period (3/21 - 3/28, 2024)  he can write a contract as below:

```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

interface IERC20 {
    function approve(address spender, uint value) external returns (bool);
}

interface IBribe {
    function addReward(address token, uint week, uint amount) external;
}
contract MyBribeTest {
    // The DYSON-USDC bribe contract on Polygon zkEVM.
    address public constant bribe = 0xFCE34AA5fc1Ca594b12248a927e0153680Ef2A90;
    address matic = 0xa2036f0538221a77A3937F1379699f44945018d0;
    uint amount = 100e18; // 100 $MATIC
    // 2024 3/21 0:00 timestamp = 1710979200
    // 1710979200/(86400*7) = 2829
    uint week = 2829
    
    function addReward() external {
        IERC20(matic).approve(bribe, amount);
        IBribe(bribe).addReward(matic, week, amount);
    }
}
```

## As a user who receive reward

Sponsor rewards will be periodically distributed at the end of the **Epoch**, and it will be distributed according to the users' $sDYSN proportion deposited in the pools at the moment. Explore the [Reward Distribution](https://docs.dyson.finance/mechanisms/gauge-and-yield-boosting#rewards-distribution) section in our white paper for further insights into sponsorship.

Users can claim their bribe reward using the below functions, by specifying the token and the week.

```solidity
// Bribe.sol
function claimReward(address token, uint week) external returns (uint amount) {
        amount = _claimReward(token, week);
        token.safeTransfer(msg.sender, amount);
    }

    function claimRewards(address token, uint[] calldata week) public returns (uint amount) {
        for(uint i = 0; i < week.length; ++i) {
            amount += _claimReward(token, week[i]);
        }
        token.safeTransfer(msg.sender, amount);
    }

    function claimRewardsMultipleTokens(address[] calldata token, uint[][] calldata week) external returns (uint[] memory amount) {
        amount = new uint[](token.length);
        for(uint i = 0; i < token.length; ++i) {
            amount[i] = claimRewards(token[i], week[i]);
        }
    }
```

The details about the `claim` functions above, please refer to [Bribe](../technical-reference/core/fee-and-reward-distribution/bribe.md) section.

#### Setup your contract

Users can check their reward on a specific pool and week by calling `checkReward` first, then claim their reward using `claimReward` as follows:

<pre class="language-solidity"><code class="lang-solidity">// SPDX-License-Identifier: UNLICENSED
<strong>pragma solidity 0.8.17;
</strong>
interface IERC20 {
    function approve(address spender, uint value) external returns (bool);
}

interface IGauge {
    function balanceOfAt(address account, uint week) external view returns (uint);
    function totalSupplyAt(uint week) external view returns (uint);
}

interface IBribe {
    function tokenRewardOfWeek(address token, uint week) external view returns (uint);
    function claimReward(address token, uint week) external returns (uint amount);
}

contract MyClaimBribeRewardTest {
    // The DYSON-USDC Gauge contract on Polygon zkEVM.
    address public constant dysonPairGauge = 0x7bC034759Cc6582926773b1094A7bEf406c2376D;
    // The DYSON-USDC bribe contract on Polygon zkEVM.
    address public constant bribe = 0xFCE34AA5fc1Ca594b12248a927e0153680Ef2A90;
    // The sDYSON contract on Polygon zkEVM.
    address public constant sDYSON = 0x8813B3EEB279A43Ac89e502e6fbe0ec89170c088;

    uint amount = 100e18; // 100 $sDYSN
    address to = address(this);

    function checkReward(address token, uint week) external returns (uint amount) {
        uint userVotes = IGauge(dysonPairGauge).balanceOfAt(msg.sender, week);
        uint totalVotes = IGauge(dysonPairGauge).totalSupplyAt(week);
        uint totalRewardAtWeek = IBribe(bribe).tokenRewardOfWeek(token, week);
        amount = totalRewardAtWeek * userVotes / totalVotes;
    }
    
    function claimReward(address token, uint week) external returns (uint) {
        return IBribe.claimReward(token, week);
    }
}
</code></pre>

