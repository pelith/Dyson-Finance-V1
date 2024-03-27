# sDYSON

## StakingRateModel Contract

The `StakingRateModel` contract calculates the expected staking rate for locked DYSON tokens based on the duration. It uses the ABDKMath64x64 library for precision.

### stakingRate

The `stakingRate` function in the `StakingRateModel` contract determines the expected staking rate, representing the conversion of $DYSN to $sDYSN, based on the specified lock duration. Key aspects include:

* **Validity Checks:** The function ensures that the provided `lockDuration` falls within an acceptable range, requiring it to be more than `30 minutes` but less than `4 years` (1461 days).
* **Calculation:** Utilizing the ABDKMath64x64 library, the function computes and returns the $DYSN-$sDYSN conversion rate, represented in the red frame in the formula:\
  ![](<../../../.gitbook/assets/image (19).png>)\
  `conversion rate (The red frame) = stakingRate * 2^(lockPeriod) / 16`\
  The initial stakingRate, originally `1e18`, is adjusted to `0.0625e18` in our contract due to pre-division by 16. The stakingRate then doubles annually.\
  LockPeriod represents the lock-up period (a year as a unit), calculated as:\
  `lockPeriod = (lockDuration + time_since_initial_time) / 1 year`\
  Conclusions:\
  4 years lock-up period will get the complete conversion rate, as `1e18` .\
  3 years lock-up period will get 50% conversion rate, as `0.5e18` .\
  2 years lock-up period will get 25% conversion rate, as `0.25e18` .\
  1 year lock-up period will get 12.5% conversion rate, as `0.125e18` .

For a detailed understanding of the staking rate and the conversion from $DYSN to $sDYSN, please refer to the [_Conversion Rate_](https://docs.dyson.finance/mechanisms/staking-and-voting#conversion-rate) section in our white paper.

```solidity
function stakingRate(
    uint lockDuration) external view returns (uint rate)
```

Parameters:

<table><thead><tr><th width="159">Name</th><th width="95">Type</th><th>Description</th></tr></thead><tbody><tr><td>lockDuration</td><td>uint</td><td>Calculates the expected staking rate based on the lock duration and time since the initial time.</td></tr></tbody></table>

## sDYSON Contract

sDYSON is an ERC20 contract for Staked $DYSON, supporting cross-chain transfers.

### addMinter

Adds an address as a minter, allowing it to mint new sDYSON tokens.

```solidity
function addMinter(
    address _minter) external onlyOwner
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>_minter</td><td>address</td><td>Address to be added as a minter.</td></tr></tbody></table>

### removeMinter

Removes an address from the list of minters, preventing it from minting new sDYSON tokens.

```solidity
function removeMinter(
    address _minter) external onlyOwner
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>_minter</td><td>address</td><td>Address to be removed from minters.</td></tr></tbody></table>

### setUnbackedSupplyCap

Sets the cap for unbacked sDYSON supply.

```solidity
function setUnbackedSupplyCap(
    int256 _unbackedSupplyCap) external onlyOwner
```

Parameters:

<table><thead><tr><th width="211">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>_unbackedSupplyCap</td><td>int</td><td>New cap for unbacked sDYSON supply.</td></tr></tbody></table>

### approve

Approves the spender to spend a specified amount of sDYSON tokens on behalf of the owner.

```solidity
function approve(
    address spender, 
    uint amount) external returns (bool)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>spender</td><td>address</td><td>Address allowed to spend the tokens.</td></tr><tr><td>amount</td><td>uint</td><td>Amount of tokens to approve.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>None</td><td>bool</td><td>Boolean indicating success.</td></tr></tbody></table>

### transfer

Transfers a specified amount of sDYSON tokens to a target address.

```solidity
function transfer(
    address to, 
    uint amount) external returns (bool)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="360">Description</th></tr></thead><tbody><tr><td>to</td><td>address</td><td>Address to which tokens will be transferred.</td></tr><tr><td>amount</td><td>uint</td><td>Amount of tokens to transfer.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>None</td><td>bool</td><td>Boolean indicating success.</td></tr></tbody></table>

### transferFrom

Transfers a specified amount of sDYSON tokens from one address to another, subject to approval.

```solidity
function transferFrom(
    address from, 
    address to, 
    uint amount) external returns (bool)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>from</td><td>address</td><td>Address from which tokens will be transferred.</td></tr><tr><td>to</td><td>address</td><td>Address to which tokens will be transferred.</td></tr><tr><td>amount</td><td>uint</td><td>Amount of tokens to transfer.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>None</td><td>bool</td><td>Boolean indicating success.</td></tr></tbody></table>

### getStakingRate

Gets the staking rate based on the lock duration by calling `stakingRate` function in StakingRateModel contract.

```solidity
function getStakingRate(uint lockDuration) public view returns (uint rate)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>lockDuration</td><td>uint</td><td>Duration for which DYSON tokens are locked.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>rate</td><td>uint</td><td>Staking rate.</td></tr></tbody></table>

### setStakingRateModel

Sets a new StakingRateModel contract.

```solidity
function setStakingRateModel(
    address newModel) external onlyOwner
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>newModel</td><td>address</td><td>Address of the new StakingRateModel contract.</td></tr></tbody></table>

### setMigration

Sets a new migration contract for user vault migration.

```solidity
function setMigration(
    address _migration) external onlyOwner
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>_migration</td><td>address</td><td>Address of the new migration contract.</td></tr></tbody></table>



### mint

This function generates unbacked sDYSON tokens for cross-chain transfers. It performs the following steps:

* Verifies that the mint amount is below the `MAX_MINT_AMOUNT_LIMIT`, set at `2^255`.
* Ensures the total unbacked supply remains under the specified `unbackedSupplyCap` after minting.
* Updates the unbacked supply.
* Invokes the `_mint` function.

```solidity
function mint(
    address to, 
    uint amount) external returns (bool)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>to</td><td>address</td><td>Address to receive the minted tokens.</td></tr><tr><td>amount</td><td>uint</td><td>Amount of tokens to mint.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>None</td><td>bool</td><td>Boolean indicating success.</td></tr></tbody></table>

### burn

Burns unbacked sDYSON tokens. This function burns unbacked sDYSON tokens for cross-chain transfers. It simply decreases unbacked supply and call `_burn` function.

```solidity
function burn(uint amount) external returns (bool)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>amount</td><td>uint</td><td>Amount of tokens to burn.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>None</td><td>bool</td><td>Boolean indicating success.</td></tr></tbody></table>

### stake

This function allows users to stake DYSON tokens, earn sDYSON tokens based on the staking rate and lock duration, and records relevant details in the vault. Key actions performed by this function include:

1. Determining the sDYSON amount to be minted based on the staking rate and the provided lock duration.
2. Recording the staking details in the vault, including the amount of DYSON staked, the corresponding sDYSON amount, and the unlock time.
3. Updating the total DYSON amount staked and the voting power for the staker.
4. Minting the calculated sDYSON tokens and transferring the staked DYSON tokens to the contract.

The sDYSON amount to be minted is determined by the formula below:

```solidity
sDysonAmount = getStakingRate(lockDuration) * amount / STAKING_RATE_BASE_UNIT 
```

Here's a breakdown of the components in this formula:

* `amount` : The amount of DYSON tokens being staked.
* &#x20;`STAKING_RATE_BASE_UNIT`: A constant representing the base unit for the staking rate which is set as `1e18` .
* `getStakingRate(lockDuration)`: The staking rate calculated based on the lock duration using the `getStakingRate` function. It would be  `0 < stakingRate <= 1e18`.

```solidity
function stake(
    address to, 
    uint amount, 
    uint lockDuration) external returns (uint sDysonAmount)
```

Parameters:&#x20;

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>to</td><td>address</td><td>Address that owns the new vault.</td></tr><tr><td>amount</td><td>uint</td><td>Amount of DYSON to stake.</td></tr><tr><td>lockDuration</td><td>uint</td><td>Duration to lock DYSON.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="359">Description</th></tr></thead><tbody><tr><td>sDysonAmount</td><td>uint</td><td>Amount of sDYSON minted to the new vault.</td></tr></tbody></table>

### restake

This function allows a user to stake additional DYSON tokens to an existing vault, extending the lock duration. The user can restake even when the vault is already unlocked, and the new unlock time must be greater than the old unlock time. The function calculates the additional sDYSON tokens to be minted based on the updated staking rate and the added DYSON amount.

the `sDysonAmountNew` is calculated to determine the additional sDYSON tokens to be minted when a user restakes additional DYSON tokens to an existing vault. The formula used for this calculation is:

```solidity
sDysonAmountNew = (vault.dysonAmount + amount) * getStakingRate(lockDuration) / STAKING_RATE_BASE_UNIT;
```

Here's a breakdown of the components in this formula:

* `vault.dysonAmount`: The current amount of DYSON tokens in the user's vault before the restake operation.
* `amount`: The additional amount of DYSON tokens being staked in the restake operation.
* `getStakingRate(lockDuration)`: The staking rate calculated based on the lock duration using the `getStakingRate` function.
* `STAKING_RATE_BASE_UNIT`: A constant representing the base unit for the staking rate which is set as `1e18` .

The formula combines the existing DYSON amount in the vault with the additional staked amount and adjusts it based on the calculated staking rate. The result is the new amount of sDYSON tokens to be minted and added to the user's vault.

This calculation ensures that the minted sDYSON amount accurately reflects the updated staking conditions, allowing users to receive rewards proportional to their additional stake and the adjusted staking rate.

```solidity
function restake(
    uint index, 
    uint amount, 
    uint lockDuration) external returns (uint sDysonAmountAdded)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>index</td><td>uint</td><td>Index of the user's vault to restake.</td></tr><tr><td>amount</td><td>uint</td><td>Amount of DYSON to restake.</td></tr><tr><td>lockDuration</td><td>uint</td><td>Duration to lock DYSON.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="218">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>sDysonAmountAdded</td><td>uint</td><td>Amount of new sDYSON minted to the user's vault.</td></tr></tbody></table>

### unstake

This function performs the unstaking of sDYSON tokens and the corresponding withdrawal of DYSON tokens. Here are the key steps involved in the `unstake` function:

1. **Vault Retrieval & Unlock Time Check:**
   * Retrieves the user's vault based on the provided `index` and checks if the unlock time for the vault has been reached (vault is unlocked).
2. **Amount Calculation:**
   * Calculates the amount of DYSON tokens to be withdrawn based on the proportion of `sDysonAmount` relative to the total sDYSON amount in the vault.
3. **Vault Updates & Global Updates:**
   * Updates the vault's `dysonAmount` and `sDysonAmount` by subtracting the calculated amounts.
   * Decreases the total DYSON amount staked and the user's voting power by the amounts withdrawn.
4. **Token Transfer:**
   * Calls the internal `_burn` function to burn the corresponding sDYSON tokens.
   * Transfers the calculated amount of DYSON tokens from the contract to the specified `to` address.

```solidity
function unstake(
    address to, 
    uint index, 
    uint sDysonAmount) external returns (uint amount)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>to</td><td>address</td><td>Address that will receive DYSON.</td></tr><tr><td>index</td><td>uint</td><td>Index of the user's vault to unstake.</td></tr><tr><td>sDysonAmount</td><td>uint</td><td>Amount of sDYSON to unstake.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>amount</td><td>uint</td><td>Amount of DYSON transferred.</td></tr></tbody></table>

### migrate

This function allows a user to migrate their vault to a new staking contract. The owner must set the migration contract before initiating migration, and the migration contract must implement the `onMigrationReceived` function. The user specifies the index of the vault to migrate, and the associated DYSON and sDYSON amounts, along with the unlock time, are transferred to the migration contract. The migration contract is then notified of the migration.

```solidity
function migrate(
    uint index) external
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>index</td><td>uint</td><td>Index of the user's vault to migrate.</td></tr></tbody></table>

### rescueERC20

```solidity
function rescueERC20(
    address tokenAddress, 
    address to,
    uint256 amount) onlyOwner external
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>tokenAddress</td><td>address</td><td>Address of the ERC-20 token to be rescued.</td></tr><tr><td>to</td><td>address</td><td>Address that will receive the rescued tokens.</td></tr><tr><td>amount</td><td>uint</td><td>Amount of tokens to be rescued.</td></tr></tbody></table>

### permit

Implements the EIP-2612 permit function, allowing an owner to approve token spending with a signature.

```solidity
function permit(
    address _owner,
    address _spender,
    uint256 _amount,
    uint256 _deadline,
    uint8 _v,
    bytes32 _r,
    bytes32 _s) external
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>_owner</td><td>address</td><td>Token owner's address.</td></tr><tr><td>_spender</td><td>address</td><td>Address allowed to spend the tokens.</td></tr><tr><td>_amount</td><td>uint</td><td>Amount of tokens to approve.</td></tr><tr><td>_deadline</td><td>uint</td><td>Deadline for the permit.</td></tr><tr><td>_v</td><td>uint8</td><td>Must produce a valid secp256k1 signature from the holder along with _r <em>and</em> _s.</td></tr><tr><td>_r</td><td>bytes32</td><td>Must produce a valid secp256k1 signature from the holder along with _v <em>and</em>  _s.</td></tr><tr><td>_s</td><td>bytes32</td><td>Must produce a valid secp256k1 signature from the holder along with _v and _r.</td></tr></tbody></table>
