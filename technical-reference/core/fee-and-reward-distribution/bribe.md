# Bribe

Contract for third parties to bribe sDYSON holders into depositing their sDYSON in certain Gauge contract. Each Bribe contract is paired with one Gauge contract. Third parties can add multiple tokens as rewards. Please refer to [_Sponsorship_](https://docs.dyson.finance/mechanisms/gauge-and-yield-boosting#sponsorship) section in our white paper to learn more.

### addReward

Adds a reward of a given token to a specific week. Below is an introduction to what the function does:

1. **Require Statement**:
   * Ensures that the specified week is either the present week or a future week.
2. **Token Transfer**:
   * Transfers the specified amount of tokens from the caller's address to the Bribe contract.
3. **Update Total Reward**:
   * Increases the total reward amount for the given token and week by the specified amount.

This function is designed to be used by third parties to contribute rewards to the Bribe contract for specific tokens and weeks. The `require` statement ensures that rewards cannot be added for past weeks. The function provides transparency by emitting an event for every reward addition.

```solidity
function addReward(
    address token, 
    uint week, 
    uint amount) external
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>token</td><td>address</td><td>Address of the token to add as a reward.</td></tr><tr><td>week</td><td>uint</td><td>The week to add the reward to (i-th week since 1970/01/01). It must be the present week or a future week.</td></tr><tr><td>amount</td><td>uint</td><td>Amount of the token to add as a reward.</td></tr></tbody></table>

### \_claimReward

Claims the reward by the user for a specific token and week. Below is the key actions in the function:

1. **Require Statements**:
   * Ensures that the specified week is in the past.
   * Ensures that the user has not already claimed the reward for the given token and week.
2. **User and Total Votes Calculation**:
   * Retrieves the user's voting power (`userVotes`) and the total voting power (`totalVotes`) for the specified week from the associated Gauge contract.
3. **Reward Calculation**:
   * Calculates the amount of reward the user is eligible to claim based on their voting power relative to the total voting power.
4. **Mark as Claimed**:
   * Marks the reward as claimed for the user, preventing duplicate claims.

This function is internal and is used internally by the contract. It calculates and facilitates the claiming of rewards for a user for a specific token and week.

```solidity
function _claimReward(
    address token, 
    uint week) internal returns (uint amount)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>token</td><td>address</td><td>Address of the reward token.</td></tr><tr><td>week</td><td>uint</td><td>The week of the reward to claim (i-th week since 1970/01/01).</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>amount</td><td>uint</td><td>Amount of the claimed reward.</td></tr></tbody></table>

### claimReward

Enables sDYSON holders to claim rewards for a specific token and week based on `_claimReward` .

```solidity
function claimReward(
    address token, 
    uint week) external returns (uint amount)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>token</td><td>address</td><td>Address of the reward token.</td></tr><tr><td>week</td><td>uint</td><td>The week of the reward to claim (i-th week since 1970/01/01).</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>amount</td><td>uint</td><td>Amount of the claimed reward.</td></tr></tbody></table>

### claimRewards

Claims multiple rewards by the user for a specific token and multiple weeks based on `_claimReward`.

```solidity
function claimRewards(
    address token, 
    uint[] calldata week) public returns (uint amount)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>token</td><td>address</td><td>Address of the reward token.</td></tr><tr><td>week</td><td>uint[]</td><td>An array of weeks for which the user wants to claim rewards.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>amount</td><td>uint</td><td>Total amount of the claimed rewards.</td></tr></tbody></table>

### claimRewardsMultipleTokens

Claims multiple rewards for multiple tokens and multiple weeks based on `_claimReward`.

```solidity
function claimRewardsMultipleTokens(
    address[] calldata token, 
    uint[][] calldata week) external returns (uint[] memory amount)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="107">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>token</td><td>address[]</td><td>An array of addresses of reward tokens.</td></tr><tr><td>week</td><td>uint[][]</td><td>An array of arrays of weeks for which the user wants to claim rewards.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>amount</td><td>uint</td><td>An array of total amounts of the claimed rewards.</td></tr></tbody></table>

