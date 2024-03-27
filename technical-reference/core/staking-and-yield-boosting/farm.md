# Farm

This contract handles all business logic related to `Point` calculation.

### rescueERC20

Allows the owner to rescue tokens stuck in the contract

```solidity
function rescueERC20(
    address tokenAddress, 
    address to, 
    uint256 amount) onlyOwner external
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>tokenAddress</td><td>address</td><td>Address of the token to be rescued.</td></tr><tr><td>to</td><td>address</td><td>Address that will receive the rescued tokens.</td></tr><tr><td>amount </td><td>uint</td><td>Amount of tokens to be rescued.</td></tr></tbody></table>

### setPool

Sets the Gauge contract for a given pool. It associates a specified Pair (pool) with its corresponding Gauge contract. It updates the Gauge contract address, last reserve, last update time, reward rate, and weight for the pool. This function ensures that the Farm contract is aware of the parameters managed by the Gauge contract, allowing for accurate reward calculations and maintaining up-to-date information about the pool's state.

```solidity
function setPool(
    address poolId, 
    address gauge) external onlyOwner
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>poolId</td><td>address</td><td>Address of the Pair contract (pool).</td></tr><tr><td>gauge</td><td>address</td><td>Address of the Gauge contract.</td></tr></tbody></table>

### setPoolRewardRate

Updates a pool's `rewardRate` and `weight` triggered by the pool's `Gauge` contract.

```solidity
function setPoolRewardRate(
    address poolId, 
    uint rewardRate, 
    uint weight) external
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>poolId</td><td>address</td><td>Address of the Pair contract (pool).</td></tr><tr><td>rewardRate</td><td>uint</td><td>New rewardRate.</td></tr><tr><td>weight</td><td>uint</td><td>New weight.</td></tr></tbody></table>

### setGlobalRewardRate

Updates the governance token pool's `rewardRate` and `weight`.

```solidity
function setGlobalRewardRate(
    uint rewardRate, 
    uint weight) external onlyOwner
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>rewardRate</td><td>uint</td><td>New rewardRate.</td></tr><tr><td>weight</td><td>uint</td><td>New weight.</td></tr></tbody></table>

### getCurrentPoolReserve

Retrieves the present reserve amount for a specified pool. The reserve undergoes linear growth over time, following the formula:

`reserve = timeElapse * rewardRate + lastReserve`.&#x20;

For further insights into how the reward pool operates, please refer to the [Token Incentive](https://docs.dyson.finance/mechanisms/token-incentive) section in our white paper.

```solidity
function getCurrentPoolReserve(
    address poolId) public view returns (uint reserve)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>poolId</td><td>address</td><td>Address of the Pair contract (pool).</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>reserve</td><td>uint</td><td>Current reserve amount of the pool.</td></tr></tbody></table>

### getCurrentGlobalReserve

Similar to `getCurrentPoolReserve`, this function fetches the current reserve amount specifically for the governance token pool. The global reserve undergoes linear growth over time, following the formula:

`globalReserve = timeElapse * globalRewardRate + lastGlobalReserve`.&#x20;

For additional details on the reward pool mechanics, kindly refer to the [Token Incentive](https://docs.dyson.finance/mechanisms/token-incentive) section in our white paper.

```solidity
function getCurrentGlobalReserve() public view returns (uint reserve)
```

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>reserve</td><td>uint</td><td>Current reserve amount of the governance token pool.</td></tr><tr><td></td><td></td><td></td></tr></tbody></table>

### \_calcRewardAmount

This function calculates the reward amount by executing conversion calculations for both localPoint to point and point to $DYSN. The formula is articulated as:&#x20;

`reward = reserve * (1 - 2^(-amount/w))`.&#x20;

* For localPoint to point conversion, the formula becomes: \
  `point = pointReserve * (1 - 2^(-localPoint/w))`.&#x20;
* Likewise, for point to $DYSN conversion, the expression is: \
  `$DYSN = dysonReserve * (1 - 2^(-point/w))`.&#x20;
* The parameter `w` plays a crucial role in determining the sensitivity of the Point exchange rate.

This dual-purpose function provides flexibility in determining rewards across different token conversions within the system. For additional details on the reward pool mechanics, kindly refer to the [Point Calculation](https://docs.dyson.finance/mechanisms/token-incentive#point-calculation) section in our white paper.

```solidity
function _calcRewardAmount(
    uint _reserve, 
    uint _amount, 
    uint _w) internal pure returns (uint reward)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>_reserve</td><td>uint</td><td>Reserve amount.</td></tr><tr><td>_amount</td><td>uint</td><td>LocalSP or GlobalSP amount.</td></tr><tr><td>_w</td><td>uint</td><td>Weight</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>reward</td><td>uint</td><td>Amount of governance token received.</td></tr></tbody></table>

### grantSP

The `grantSP` function is triggered by the [\_grantSP](../pair.md#grantsp) function in the Pair contract to reward users with Points upon dual investment deposit. The interim value, known as `localPoint`, is computed in the Pair contract and passed as the `amount` parameter to this function. Here, the user's localPoint undergoes multiplication by a bonus ratio if the user also stakes sGov tokens (sDYSON tokens) in the pool's Gauge contract. And finally, convert the localPoint to Point. The steps are as follows:

1. Retrieve the `bonus ratio` by invoking the `bonus` function in the pool's Gauge contract, where the maximum ratio returned is 1.5e18. For detailed bonus calculations, refer to the [bonus](gauge.md#bonus) section in the Gauge contract.
2. Enhance the user's localPoint by the bonus ratio if the user holds voting power through sGov token deposits. The formula used is: \
   `localPoint = localPoint * (bonus + 1e18) / 1e18;`. \
   This boosts the localPoint based on the user's voting power, with the potential for a maximum `2.5x` boost, given the maximum bonus of `1.5e18` obtained from the Gauge contract.
3. Convert the user's localPoint to Points by calling the `_calcRewardAmount` function.

For additional details on the reward pool mechanics, kindly refer to the [Point Calculation](https://docs.dyson.finance/mechanisms/token-incentive#point-calculation) section in our white paper.

```solidity
function grantSP(
    address to, 
    uint amount) external
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>to</td><td>address</td><td>User's address.</td></tr><tr><td>amount</td><td>uint</td><td>Amount of localSP.</td></tr></tbody></table>

### swap

This function allows a third party to convert a user's Points to the governance token ($DYSN) following these key rules:

* **Accessibility:** Any third party can trigger this function.
* **Cooldown Requirement:** Users can only perform a swap after their cooldown period ends, determined by their generation in the referral system.
* **Referral System Registration:** To initiate a swap, users must be registered in the referral system. Upon swapping, the user's referrer receives 1/3 of the user's Points.

The function carries out the following tasks:

1. **Point to $DYSN Conversion:** It uses the `_calcRewardAmount` function to convert the user's Points to $DYSN, minting the corresponding $DYSN tokens to the user while resetting their Points to zero.
2. **Referrer Bonus:** An extra 1/3 of the swapped Points is minted and awarded to the user's referrer.
3. **Global Pool Update:** The global pool's reserve is updated to maintain an accurate representation of the overall system state.

```solidity
function swap(
    address user) external returns (uint amountOut)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>user</td><td>address</td><td>User's address.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>amountOut</td><td>uint</td><td>Amount of governance token received.</td></tr></tbody></table>

