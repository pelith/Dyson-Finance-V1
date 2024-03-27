# Gauge

Gauge is a voting contract for liquidity pools, with each liquidity pool having its own Gauge contract.

### rescueERC20

Rescues tokens stuck in the contract.

```solidity
function rescueERC20(
    address tokenAddress, 
    address to, 
    uint256 amount) onlyOwner external
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>tokenAddress</td><td>address</td><td>Address of the token to be rescued.</td></tr><tr><td>to</td><td>address</td><td>Address that will receive the tokens.</td></tr><tr><td>amount</td><td>uint</td><td>Amount of tokens to be rescued.</td></tr></tbody></table>

### setParams

Sets parameters (`weight`, `base`, and `slope`) of the Gauge contract.

* `weight`: Weight determines the how much reward user can earn in Farm contract.  The higher the weight, the lower the reward.
* `base` : Base reward rate.&#x20;
* `slope` : Slope of reward rate.

Please refer to [Point voting](https://docs.dyson.finance/mechanisms/gauge-and-yield-boosting#point-voting) to learn more about `ratePoint` calculation.

```solidity
function setParams(
    uint _weight, 
    uint _base, 
    uint _slope) external onlyOwner
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>_weight</td><td>uint</td><td>New weight.</td></tr><tr><td>_base</td><td>uint</td><td>New base reward rate.</td></tr><tr><td>_slope</td><td>uint</td><td>New slope of the reward rate.</td></tr></tbody></table>

### balanceOf

Retrieves the user's latest balance, i.e., balance recorded in the user's latest checkpoint.

```solidity
function balanceOf(
    address account) public view returns (uint)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>account</td><td>address</td><td>User's address.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>balance</td><td>uint</td><td>User's latest balance.</td></tr></tbody></table>

### balanceOfAt

Retrieves the user's balance at a given week. If no checkpoint is recorded at the given week, it searches for the latest checkpoint among previous ones.

```solidity
function balanceOfAt(
    address account, 
    uint week) external view returns (uint)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>account</td><td>address</td><td>User's address.</td></tr><tr><td>week</td><td>uint</td><td>The week to find out the user's balance.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>balance</td><td>uint</td><td>User's balance at the given week.</td></tr><tr><td></td><td></td><td></td></tr></tbody></table>

### totalSupplyAt

Total supply at a given week.

```solidity
function totalSupplyAt(
    uint week) public view returns (uint)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>week</td><td>uint</td><td>The week to find out the total supply.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>totalSupply</td><td>uint</td><td>Total supply.</td></tr><tr><td></td><td></td><td></td></tr></tbody></table>

### tick

This function serves the purpose of updating the contract's state, specifically handling the transition to a new week. Below is an introduction to what the `tick` function does:

1. **Week Update:**
   * The function first calculates the current week based on the current timestamp divided by the duration of a week (1 week). The result is stored in the `_week` variable.
2. **Checkpoint and Total Supply Update:**
   * If the calculated `_week` is greater than the current `thisWeek` stored in the contract, it means a new week has begun.
   * For each week between the current `thisWeek` and the new `_week` (exclusive), the function updates the total supply checkpoint (`_totalSupplyAt`) with the current `totalSupply`.
   * The `thisWeek` is then updated to the new `_week`.
3. **Reward Rate Update:**
   * The function calls the internal `_updateRewardRate` function to update the reward rate recorded in the associated Farm contract based on the latest total supply and the configured slope and base values.

```solidity
function tick() public
```

### updateTotalSupply

Update latest total supply and trigger `tick`.

```solidity
function updateTotalSupply(
    uint _totalSupply) internal
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>_totalSupply</td><td>uint</td><td>New total supply.</td></tr></tbody></table>

### nextRewardRate

Compute new reward rate base on latest `totalSupply`, `slope` and `base.` The formula is as follows:

```solidity
newRewardRate = totalSupply * slope / REWARD_RATE_BASE_UNIT + base;
```

* `totalSupply`: This represents the total supply of the sGov token in the Gauge contract. It's the sum of all the sGov tokens deposited by users.
* `slope`: This is a configurable parameter that determines the rate at which the reward rate increases based on the total supply. A higher slope means a faster increase in the reward rate.
* `REWARD_RATE_BASE_UNIT`: This is a constant value set as `1e18` representing the base unit for the reward rate. It's used to ensure that the result is in the correct units.
* `base`: This is another configurable parameter that represents the base reward rate. It's the minimum reward rate that the contract will provide, irrespective of the total supply.

Please refer to [Point voting](https://docs.dyson.finance/mechanisms/gauge-and-yield-boosting#point-voting) to learn more about reward rate calculation.

```solidity
function nextRewardRate() public view returns (uint newRewardRate)
```

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>newRewardRate</td><td>uint</td><td>New reward rate.</td></tr></tbody></table>

### deposit

Deposits sGOV tokens on behalf of a user. This function plays a crucial role in the liquidity mining mechanism, where users deposit sGov tokens to earn additional rewards. Below is an introduction to what the `deposit` function does:

1. **Token Transfer:**
   * Transfers the specified amount of sGov tokens from the sender's address to the Gauge contract. This requires prior approval of the sGov token by the user.
2. **Checkpoint Update:**
   * Records a new checkpoint for the user, updating their balance with the deposited amount. This allows the contract to keep track of the user's historical balances.
3. **Total Supply Update:**
   * Updates the total supply of sGov tokens in the Gauge by adding the deposited amount. This is essential for calculating the reward rates accurately.

Please refer to [_Boost_](../../../guides/boost-the-pool-by-depositing-your-usdsdysn.md) section to learn more about performing a deposit to Gauge.\


```solidity
function deposit(
    uint amount, 
    address to) external
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>amount</td><td>uint</td><td>Amount of sGOV tokens to deposit.</td></tr><tr><td>to</td><td>address</td><td>Address that owns the amount of sGOV tokens.</td></tr></tbody></table>

### applyWithdrawal

This function allows users to initiate the process of withdrawing their sGov tokens from the Gauge. This function introduces a delay of one week before the actual withdrawal occurs. Users must call this function to express their intent to withdraw, and the withdrawal will be processed after the specified delay. Below is an introduction to what the `applyWithdrawal` function does:

1. **Checkpoint Update:**
   * &#x20;Updates the user's checkpoint by reducing their recorded balance by the withdrawal amount. This reflects the intention to withdraw in the historical balance records.
2. **Total Supply Update:**
   * Decreases the total supply of sGov tokens in the Gauge, accounting for the pending withdrawal. This ensures accurate reward rate calculations.
3. **Pending Withdrawal Record:**
   * Records the withdrawal amount as pending for the user. This amount will be available for withdrawal after the specified delay.
4. **Week to Withdraw Update:**
   * Sets the week when the user can complete the withdrawal. The withdrawal delay is one week, so it will be processed in the subsequent week.

```solidity
function applyWithdrawal(
    uint amount) external
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>amount</td><td>uint</td><td>Amount of sGOV tokens to withdraw.</td></tr></tbody></table>

### withdraw

The `withdraw` function in the Gauge contract allows users to complete their withdrawal of sGov tokens. This function is typically called after a one-week delay from the time the user initiated the withdrawal by calling the `applyWithdrawal` function. The purpose of the delay is to allow for a period during which the user's withdrawal request can be processed and confirmed. Below is an introduction to what the `withdraw` function does:

1. **Requirements:**
   * Ensures that the withdrawal can only be completed after the specified one-week delay has passed. Also Ensures that the withdrawal amount is non-zero.
2. **Amount Calculation:**
   * Retrieves the amount of sGov tokens that was previously marked as pending for withdrawal.
3. **Pending Withdrawal Clearing:**
   * Clears the pending withdrawal amount for the user after successfully completing the withdrawal.
4. **Token Transfer:**
   * Transfers the withdrawn sGov tokens from the Gauge contract to the user's address.

```solidity
function withdraw() external returns (uint amount)
```

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>amount</td><td>uint</td><td>Amount of sGOV tokens withdrawn.</td></tr></tbody></table>

### bonus

This function calculates the bonus ratio for a user based on their latest balance of sGov tokens. The bonus ratio is designed to provide additional rewards to users with smaller balances, encouraging broader participation. The formula for calculating the bonus is as follows:

```solidity
_bonus = (balance * BONUS_MULTIPLIER / totalSupply).sqrt();
_bonus = _bonus > MAX_BONUS ? MAX_BONUS : _bonus;
```

* `balance`: Represents the user's latest balance of sGov tokens.
* `BONUS_MULTIPLIER`: A constant factor used to scale the bonus calculation which is set as `22.5e36`.
* `totalSupply`: Refers to the total supply of sGov tokens in the Gauge contract.
* `_bonus`: The calculated bonus ratio for the user.
* `MAX_BONUS:` The max bonus ratio is set as `1.5e18` . Bonus ratio approaches max when the user's balance gets closer to 1/10 of total supply.

The formula computes a preliminary bonus value, adjusts it using the square root operation, and then caps the final bonus ratio at a specified maximum value (`MAX_BONUS`). The intention is to incentivize users with smaller balances by providing a non-linear bonus that diminishes as the user's balance increases.

```solidity
function bonus(
    address user) external view returns (uint _bonus)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>user</td><td>address</td><td>User's address.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>_bonus</td><td>uint</td><td>User's bonus ratio.</td></tr></tbody></table>

