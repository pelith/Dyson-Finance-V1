# Pair

## FeeModel Contract

The FeeModel contract is specifically crafted to facilitate the calculation of trading fees, incorporating our economic formula.

### \_getFeeRatioStored

Get the stored variables including fee ratio and last update time of token0 and token1.

```solidity
function _getFeeRatioStored(
) internal view returns (uint64 _feeRatio0, uint64 _feeRatio1, uint64 _lastUpdateTime0, uint64 _lastUpdateTime1)
```

Return Values:

<table><thead><tr><th width="191">Name</th><th width="85">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>_feeRatio0</td><td>uint64</td><td>Stored fee ratio of token0</td></tr><tr><td>_feeRatio1</td><td>uint64</td><td>Stored fee ratio of token1</td></tr><tr><td>_lastUpdateTime0</td><td>uint64</td><td>Stored last update time of token0</td></tr><tr><td>_lastUpdateTime1</td><td>uint64</td><td>Stored last update time of token1</td></tr></tbody></table>



### \_calcFeeRatioAdded

Calculate new fee ratio when fee ratio is increased.

Whenever a swap occurs that results in a y% decrease in the reserve of token0 in the pool, the system sets a fee of y% on token0. If the pool already had an x% fee at the time, an additional y% fee is added. For the new fee calculation formula please refer to below:

Formula: `newFeeRatio = 1 - (1 - x%)(1 - y%)`

Breaking down the formula, we can rearrange it as `1 - (1 - a)(1 - b) = a + b - ab`, reflecting the logic `newFeeRatio = before + added - before * added`. Translating this formula into code, we get:

`_newFeeRatio = uint64(before + added - before * added / MAX_FEE_RATIO);`

* `MAX_FEE_RATIO` : In a typical scenario, the maximum fee ratio would be 1. However, in this context, we set the max fee ratio to `2**64` due to limitations in the Solidity language (which does not support decimal numbers) and for the sake of simpler calculations. You'll notice that every time we calculate a feeRatio for a swap fee, we use the formula: `fee = swapAmount * feeRatio / MAX_FEE_RATIO`.

Explore the [_Trading Fee Calculation_](https://docs.dyson.finance/mechanisms/dynamic-amm#trading-fee-calculation) section in our white paper for comprehensive insights into the fee calculation mechanism.

```solidity
function _calcFeeRatioAdded(
    uint64 _feeRatioBefore, 
    uint64 _feeRatioAdded
) internal pure returns (uint64 _newFeeRatio)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="85">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>_feeRatioBefore</td><td>uint64</td><td>Fee ratio before the increase</td></tr><tr><td>_feeRatioAdded</td><td>uint64</td><td>Fee ratio increased</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="85">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>_newFeeRatio</td><td>uint64</td><td>New fee ratio</td></tr></tbody></table>



### \_updateFeeRatio0

Update `feeRatio0` by calling `_calcFeeRatioAdded` and last update timestamp of token0.

```solidity
function _updateFeeRatio0(
    uint64 _feeRatioBefore, 
    uint64 _feeRatioAdded) internal
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="85">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>_feeRatioBefore</td><td>uint64</td><td>Fee ratio before the increase</td></tr><tr><td>_feeRatioAdded</td><td>uint64</td><td>Fee ratio increased</td></tr></tbody></table>

### \_updateFeeRatio1

Update `feeRatio1` by calling `_calcFeeRatioAdded` and last update timestamp of token1.

```solidity
function _updateFeeRatio1(
    uint64 _feeRatioBefore, 
    uint64 _feeRatioAdded) internal 
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="85">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>_feeRatioBefore</td><td>uint64</td><td>Fee ratio before the increase</td></tr><tr><td>_feeRatioAdded</td><td>uint64</td><td>Fee ratio increased</td></tr></tbody></table>

### calcNewFeeRatio

Calculate new fee ratio as time elapsed.

For users, when a trade happens, the fee ratio will increase immediately and it will reduce the gap as time goes on. The change will keep going until the trading fee reduces to zero. Assuming the parameter of half-life is t, it means the trading fee will become $$\frac{1}{2^{x/t}}$$ times of the original every `x` seconds.

Explore the [_Half-life t_](https://docs.dyson.finance/mechanisms/dynamic-amm#half-life-t) section in our white paper for comprehensive insights into the fee calculation mechanism.

```solidity
function calcNewFeeRatio(
    uint64 _oldFeeRatio, 
    uint _elapsedTime) public view returns (uint64 _newFeeRatio)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="85">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>_oldFeeRatio</td><td>uint64</td><td>Fee ratio from last update</td></tr><tr><td>_elapsedTime</td><td>uint</td><td>Time since last update</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="85">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>_newFeeRatio</td><td>uint64</td><td>New fee ratio</td></tr></tbody></table>



### getFeeRatio

Get the fee ratios after halving update using `calcNewFeeRatio`.

```solidity
function getFeeRatio() public view returns (uint64 _feeRatio0, uint64 _feeRatio1) 
```

Return Values:

<table><thead><tr><th width="191">Name</th><th width="85">Type</th><th width="344">Description</th></tr></thead><tbody><tr><td>_feeRatio0</td><td>uint64</td><td>Fee ratio of token0 after halving update</td></tr><tr><td>_feeRatio1</td><td>uint64</td><td>Fee ratio of token1 after halving update</td></tr></tbody></table>

## Feeswap Contract

The Feeswap contract, inheriting from the FeeModel contract, is crafted to implement virtual swap logic and manage trading fees.

### initialize

Initialize the contract with token0 and token1 addresses.

```solidity
function initialize(
    address _token0, 
    address _token1) public virtual
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="98">Type</th><th width="344">Description</th></tr></thead><tbody><tr><td>_token0</td><td>address</td><td>token0 address</td></tr><tr><td>_token1</td><td>address</td><td>token1 address</td></tr></tbody></table>

### getReserves

Retrieve the current reserves for both token0 and token1. The reserves are calculated by subtracting the accumulatedFee from the pool token balance.

In our future vision, following each trade, 50% of the generated trading fees will be retained in the pool as Protocol Controlled Value (PCV). The yet-to-be-collected trading fee revenue is referred to as accumulatedFee. For instance, the formula to determine the token0 reserve in the pair is expressed as follows:

`reserve0 = IERC20(token0).balanceOf(address(this)) - accumulatedFee0;`

Explore the [_Fee Revenue Sharing_](https://docs.dyson.finance/mechanisms/dynamic-amm#fee-revenue-sharing) section in our white paper for comprehensive insights into the fee calculation mechanism.

```solidity
function getReserves() public view returns (uint reserve0, uint reserve1)
```

Return Values:

<table><thead><tr><th width="191">Name</th><th width="98">Type</th><th width="344">Description</th></tr></thead><tbody><tr><td>reserve0</td><td>uint</td><td>Current reserve of token0</td></tr><tr><td>reserve1</td><td>uint</td><td>Current reserve of token1</td></tr></tbody></table>

### \_swap0in

Compute the swap fee and output amount based on the input amount, pool reserve, and fee ratio. Please note that this internal function solely handles the calculation and does not execute an actual swap.

```solidity
function _swap0in(
    uint input, 
    uint minOutput) internal returns (uint fee, uint output)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="98">Type</th><th width="344">Description</th></tr></thead><tbody><tr><td>input</td><td>uint</td><td>Amount of token0 to swap</td></tr><tr><td>minOutput</td><td>uint</td><td>Minimum amount of token1 expected to receive</td></tr></tbody></table>

Return values:

<table><thead><tr><th width="191">Name</th><th width="98">Type</th><th width="344">Description</th></tr></thead><tbody><tr><td>fee</td><td>uint</td><td>Amount of token0 as fee</td></tr><tr><td>output</td><td>uint</td><td>Amount of token1 swapped</td></tr></tbody></table>

### \_swap1in

Compute the swap fee and output amount based on the input amount, pool reserve, and fee ratio. Please note that this internal function solely handles the calculation and does not execute an actual swap.

```solidity
function _swap1in(
    uint input, 
    uint minOutput) internal returns (uint fee, uint output)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="98">Type</th><th width="344">Description</th></tr></thead><tbody><tr><td>input</td><td>uint</td><td>Amount of token1 to swap</td></tr><tr><td>minOutput</td><td>uint</td><td>Minimum amount of token0 expected to receive</td></tr></tbody></table>

Return values:

<table><thead><tr><th width="191">Name</th><th width="98">Type</th><th width="344">Description</th></tr></thead><tbody><tr><td>fee</td><td>uint</td><td>Amount of token1 as fee</td></tr><tr><td>output</td><td>uint</td><td>Amount of token0 swapped</td></tr></tbody></table>

### swap0in

Execute a swap from token0 to token1 by following these steps:

1. Invoke the `_swap0in` function to obtain the fee and output amount.
2. If the `feeTo` address in the contract is set, update `accumulatedFee0` by incorporating half of the fee into it.
3. Execute the actual swap.

```solidity
function swap0in(
    address to, 
    uint input, 
    uint minOutput) external lock returns (uint output)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="98">Type</th><th width="344">Description</th></tr></thead><tbody><tr><td>to</td><td>address</td><td>Address to receive swapped token1</td></tr><tr><td>input</td><td>uint</td><td>Amount of token0 to swap</td></tr><tr><td>minOutput</td><td>uint</td><td>Minimum amount of token1 expected to receive</td></tr></tbody></table>

Return Values

<table><thead><tr><th width="191">Name</th><th width="98">Type</th><th width="344">Description</th></tr></thead><tbody><tr><td>output</td><td>uint</td><td>Amount of token1 swapped</td></tr></tbody></table>



### swap1in

Execute a swap from token1 to token0 by following these steps:

1. Invoke the `_swap1in` function to obtain the fee and output amount.
2. If the `feeTo` address in the contract is set, update `accumulatedFee1` by incorporating half of the fee into it.
3. Execute the actual swap.

```solidity
function swap1in(
    address to, 
    uint input, 
    uint minOutput) external lock returns (uint output)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="98">Type</th><th width="344">Description</th></tr></thead><tbody><tr><td>to</td><td>address</td><td>Address to receive swapped token0</td></tr><tr><td>input</td><td>uint</td><td>Amount of token1 to swap</td></tr><tr><td>minOutput</td><td>uint</td><td>Minimum amount of token0 expected to receive</td></tr></tbody></table>

Return Valus:

<table><thead><tr><th width="191">Name</th><th width="98">Type</th><th width="344">Description</th></tr></thead><tbody><tr><td>output</td><td>uint</td><td>Amount of token0 swapped</td></tr></tbody></table>

### collectFee

Collect accumulated fees and transfer to the fee recipient.

This function transfers the `accumulatedFee0` and `accumulatedFee1` of token0 and token1 to the `feeTo` address if `feeTo` is configured in the pair contract. After fee collection, both `accumulatedFee0` and `accumulatedFee1` will reset to zero.

```solidity
function collectFee() external lock 
```

## Pair Contract

Pair, which inherits Feeswap contract, represents the pool contract in Dyson Finance. The Dyson Finance V1 supports WETH-USDC and DYSON-USDC pools.

### getPremium

Calculate `premium`  based on the lock time of a dual investment deposit. The governance, or controller of the factory contract, has the authority to set the volatility, impacting the premium. The formula is expressed as follows:

`Premium = volatility * sqrt(time / 365 days) * 0.4`

Let's break down the formula using an example of investing for 1 day. In code, it looks like this:

`premium = basis * 20936956903608548 / PREMIUM_BASE_UNIT`

* `basis` : Represents the chosen volatility set by the governance.
* `20936956903608548` : This is a pre-calculated result, representing the square root of (time / 365 days) \* 0.4. This pre-calculation is done in advance to optimize gas usage.
* `PREMIUM_BASE_UNIT` : It serves as a scaling factor, ensuring the correct scale is applied (set as 1e18).

You can explore the [_Dual Investment Premium calculation_](https://docs.dyson.finance/mechanisms/dual-investment#premium-calculation) section in our white paper[ ](https://docs.dyson.finance/mechanisms/dual-investment#premium-calculation)for comprehensive insights into the premium calculation mechanism.

```solidity
function getPremium(uint time) public view returns (uint premium) 
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="98">Type</th><th width="344">Description</th></tr></thead><tbody><tr><td>time</td><td>uint</td><td>Lock time. It can be either 1 day, 3 days, 7 days or 30 days</td></tr></tbody></table>

Return Valus:

<table><thead><tr><th width="191">Name</th><th width="98">Type</th><th width="344">Description</th></tr></thead><tbody><tr><td>premium</td><td>uint</td><td>Premium</td></tr></tbody></table>

### setBasis

Set the basis (volatility) parameter by the governance.

```solidity
function setBasis(uint _basis) external lock 
```

### setHalfLife

Set the half-life parameter by the governance.

```solidity
function setHalfLife(uint64 _halfLife) external lock 
```

### setFarm

Set the farm contract address by the governance.

```solidity
function setFarm(address _farm) external lock 
```

### setFeeTo

Set the fee recipient address by the governance.

```solidity
function setFeeTo(address _feeTo) external lock 
```

### rescueERC20

rescue token stucked in this contract

```solidity
function rescueERC20(
    address tokenAddress, 
    address to, 
    uint256 amount) external 
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="98">Type</th><th width="344">Description</th></tr></thead><tbody><tr><td>tokenAddress</td><td>address</td><td>Address of token to be rescued</td></tr><tr><td>to</td><td>address</td><td>Address that will receive token</td></tr><tr><td>amount</td><td>uint</td><td>Amount of token to be rescued</td></tr></tbody></table>

### \_addNote

Add new deposit note with adjusted amounts and due time.

This function computes the token0 and token1 amounts, inclusive of premiums, and stores them along with the deposit due time in a note within the Pair contract.

```solidity
function _addNote(
    address to, 
    bool depositToken0, 
    uint token0Amt, 
    uint token1Amt, 
    uint time, 
    uint premium) internal
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="98">Type</th><th width="344">Description</th></tr></thead><tbody><tr><td>to</td><td>address</td><td>Address of the user who will own the created note.</td></tr><tr><td>depositToken0</td><td>bool</td><td>A boolean indicating whether the deposit is in token0.</td></tr><tr><td>token0Amt</td><td>uint</td><td>Amount of token0 deposited.</td></tr><tr><td>token1Amt</td><td>uint</td><td>Amount of token1 deposited.</td></tr><tr><td>time</td><td>uint</td><td>Lock time for the deposit.</td></tr><tr><td>premium</td><td>uint</td><td>Premium, calculated based on the lock time.</td></tr></tbody></table>

### \_grantSP

A Dyson Finance member depositing tokens for dual-investment earns SP, referred to as "Point" in our white paper. This function calculates the "localPoint" amount for the depositor using the formula:

`localPoint = sqrt(input * output) * (premium / PREMIUM_BASE_UNIT)`.&#x20;

For insights into premium calculation details, please refer to the [Premium Base Unit](broken-reference). Once the localPoint is determined, the function calls `farm.grantSP()` to convert it into actual points. For further understanding of point calculation, explore the [grantSP](staking-and-yield-boosting/farm.md#grantsp) section in the Farm contract.

```solidity
function _grantSP(
    address to, 
    uint input, 
    uint output, 
    uint premium) internal 
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="98">Type</th><th width="344">Description</th></tr></thead><tbody><tr><td>to</td><td>address</td><td>Address of the user to whom SP will be granted.</td></tr><tr><td>input</td><td>uint</td><td>Input amount of the deposit.</td></tr><tr><td>output</td><td>uint</td><td>Output amount of the deposit.</td></tr><tr><td>premium</td><td>uint</td><td>Premium, calculated based on the lock time.</td></tr></tbody></table>



### deposit0

User deposit token0. This function execute the following steps:

1. Call `_swap0in()` to calculate swap fee and output (token1) amount.
2. Call `_addNote()` to create a note for depositor.
3. Calculate swap fee. Half of the swap fee goes to `feeTo` if `feeTo` is set.
4. Transfer token0 in.
5. Call `_grantSP()` to generate SP for depositor.

```solidity
function deposit0(
    address to, 
    uint input, 
    uint minOutput, 
    uint time) external lock returns (uint output)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="98">Type</th><th width="344">Description</th></tr></thead><tbody><tr><td>to</td><td>address</td><td>Address that owns the note</td></tr><tr><td>input</td><td>uint</td><td>Amount of token0 to deposit</td></tr><tr><td>minOutput</td><td>uint</td><td>Minimum amount of token1 expected to receive if the swap is performed</td></tr><tr><td>time</td><td>uint</td><td>Lock time</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="98">Type</th><th width="344">Description</th></tr></thead><tbody><tr><td>output</td><td>uint</td><td>Amount of token1 received if the swap is performed</td></tr></tbody></table>



### deposit1

User deposit token1. This function execute the following steps:

1. Call `_swap1in()` to calculate swap fee and output (token0) amount.
2. Call `_addNote()` to create a note for depositor.
3. Calculate swap fee. Half of the swap fee goes to `feeTo` if `feeTo` is set.
4. Transfer token1 in.
5. Call `_grantSP()` to generate SP for depositor.

```solidity
function deposit1(
    address to, 
    uint input, 
    uint minOutput, 
    uint time) external lock returns (uint output)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="98">Type</th><th width="344">Description</th></tr></thead><tbody><tr><td>to</td><td>address</td><td>Address that owns the note</td></tr><tr><td>input</td><td>uint</td><td>Amount of token1 to deposit</td></tr><tr><td>minOutput</td><td>uint</td><td>Minimum amount of token0 expected to receive if the swap is performed</td></tr><tr><td>time</td><td>uint</td><td>Lock time</td></tr></tbody></table>

Return values:

<table><thead><tr><th width="191">Name</th><th width="98">Type</th><th width="344">Description</th></tr></thead><tbody><tr><td>output</td><td>uint</td><td>Amount of token0 received if the swap is performed</td></tr></tbody></table>



### \_withdraw

This internal function handles the withdrawal of funds represented by a specific note from the Dyson pair contract. It calculates the amounts of `token0` and `token1` to be withdrawn based on the stored note information and market conditions.

```solidity
function _withdraw(
    address from, 
    uint index, 
    address to) internal returns (uint token0Amt, uint token1Amt)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="98">Type</th><th width="344">Description</th></tr></thead><tbody><tr><td>from</td><td>address</td><td>Address of the user withdrawing</td></tr><tr><td>index</td><td>uint</td><td>Index of the note to be withdrawn.</td></tr><tr><td>to</td><td>address</td><td>Address to receive the redeemed token0 or token1</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="98">Type</th><th width="344">Description</th></tr></thead><tbody><tr><td>token0Amt</td><td>address</td><td>Amount of token0 withdrawn</td></tr><tr><td>token1Amt</td><td>uint</td><td>Amount of token1 withdrawn</td></tr></tbody></table>



### withdraw

This external function allows a user to withdraw funds represented by a specific note. It calls the internal `_withdraw` function after acquiring a lock to prevent re-entrancy.

```solidity
function withdraw(
    uint index, 
    address to) external lock returns (uint token0Amt, uint token1Amt)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="98">Type</th><th width="344">Description</th></tr></thead><tbody><tr><td>index</td><td>uint</td><td>Index of the note to be withdrawn.</td></tr><tr><td>to</td><td>address</td><td>Address to receive the redeemed token0 or token1</td></tr></tbody></table>

Return values:

<table><thead><tr><th width="191">Name</th><th width="98">Type</th><th width="344">Description</th></tr></thead><tbody><tr><td>token0Amt</td><td>address</td><td>Amount of token0 withdrawn</td></tr><tr><td>token1Amt</td><td>uint</td><td>Amount of token1 withdrawn</td></tr></tbody></table>



### withdrawFrom

This external function allows an approved operator to withdraw funds represented by a specific note on behalf of a user. It calls the internal `_withdraw` function. Please refer to [Perform a withdrawal](../../guides/integration-of-dual-investment/perform-a-dual-investment-withdrawal.md#id-1.-direct-withdraw-within-pair-contract) to learn more about `withdrawFrom`.

```solidity
function withdrawFrom(
    address from, 
    uint index, 
    address to) external returns (uint token0Amt, uint token1Amt)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="98">Type</th><th width="344">Description</th></tr></thead><tbody><tr><td>from</td><td>address</td><td>Address of the user withdrawing</td></tr><tr><td>index</td><td>uint</td><td>Index of the note to be withdrawn.</td></tr><tr><td>to</td><td>address</td><td>Address to receive the redeemed token0 or token1</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="98">Type</th><th width="344">Description</th></tr></thead><tbody><tr><td>token0Amt</td><td>address</td><td>Amount of token0 withdrawn</td></tr><tr><td>token1Amt</td><td>uint</td><td>Amount of token1 withdrawn</td></tr></tbody></table>

### setApprovalForAllWithSig

This external function allows a user to approve or revoke an operator's ability to withdraw notes on their behalf using a signature. The signature must be valid and provided by the owner. Please refer to [Perform a withdrawal](../../guides/integration-of-dual-investment/perform-a-dual-investment-withdrawal.md#id-1.-direct-withdraw-within-pair-contract) to learn more about `setApprovalForAllWithSig`.

```solidity
function setApprovalForAllWithSig(
    address owner, 
    address operator, 
    bool approved, 
    uint deadline, 
    bytes calldata sig) external
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="98">Type</th><th width="344">Description</th></tr></thead><tbody><tr><td>owner</td><td>address</td><td>Address of the user who owns the note</td></tr><tr><td>operator</td><td>address</td><td>Address of the operator</td></tr><tr><td>approved</td><td>bool</td><td>A boolean indicating whether to approve (true) or revoke (false) the operator.</td></tr><tr><td>deadline</td><td>uint</td><td>Deadline for the approval signature.</td></tr><tr><td>sig</td><td>bytes</td><td>The approval signature.</td></tr></tbody></table>

### setApprovalForAll

This external function allows a user to approve or revoke an operator's ability to withdraw notes on their behalf without using a signature. Please refer to [Perform a withdrawal](../../guides/integration-of-dual-investment/perform-a-dual-investment-withdrawal.md#id-1.-direct-withdraw-within-pair-contract) to learn more about `setApprovalForAllWithSig`.

```solidity
function setApprovalForAll(
    address operator, 
    bool approved) external
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="98">Type</th><th width="344">Description</th></tr></thead><tbody><tr><td>operator</td><td>address</td><td>Address of the operator to be approved or revoked.</td></tr><tr><td>approved</td><td>bool</td><td>A boolean indicating whether to approve (true) or revoke (false) the operator.</td></tr></tbody></table>
