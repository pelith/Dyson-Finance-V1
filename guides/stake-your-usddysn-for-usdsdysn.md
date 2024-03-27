# Stake your $DYSN for $sDYSN

## Executing a Stake

Staking $DYSN for $sDYSN offers multiple advantages to holders. By holding $sDYSN, users acquire voting power. Simultaneously, they can deposit their $sDYSN into the Gauge contract to enhance a specific pool's reward generation speed. Explore the [Staking & Voting](https://docs.dyson.finance/mechanisms/staking-and-voting) section in our white paper for further insights.

Two main methods initiate staking: direct interaction with the sDYSON contract or utilizing the Router contract. However, as the Router interaction is equivalent to the sDYSON contract, staking through Router is unnecessary unless you have a specific goal of consolidating multiple interactions into a single transaction. Here, we'll only introduce the staking method within sDYSON.

### Stake DYSON within sDYSON Contract&#x20;

You have the ability to stake $DYSN tokens on behalf of another address, generating sDYSON tokens in the process. This function encompasses the following steps:

1. Calculate the staking rate based on the lock duration.
2. Establish a vault to document the staked $DYSN amount, minted $sDYSN amount, and the unlock time.
3. Allocate the corresponding voting power to the `to` address. The received voting power is equivalent to their $sDYSN amount.

```solidity
// sDYSON.sol
function stake(
    address to, 
    uint amount, 
    uint lockDuration) external returns (uint sDysonAmount)
```

Parameters:

* `to` : Address that owns the new vault.
* `amount` : Amount of DYSON to stake.
* `lockDuration` : Duration to lock DYSON.

Return Value:

* `sDysonAmount` : Amount of sDYSON minted to the new vault.

#### Set Up your Contract

```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

interface IERC20 {
    function approve(address spender, uint value) external returns (bool);
}

interface IsDYSON {
    function stake(address to, uint amount, uint lockDuration) external returns (uint sDysonAmount);
}

contract MyStakeTest {

    // The $DYSN contract on Polygon zkEVM.
    address public constant DYSN = 0x9CBD81b43ba263ca894178366Cfb89A246D1159C;
    // The sDYSON contract on Polygon zkEVM.
    address public constant sDYSON = 0x8813B3EEB279A43Ac89e502e6fbe0ec89170c088;

    uint lockDuration = 30 days;
    uint amount = 100e18; // 100 $DYSN
    address to = address(this);

    function stake() public returns (uint sDysonAmount) {
        IERC20(DYSON).approve(sDYSON, amount);
        sDysonAmount = IsDYSON(sDYSON).stake(to, amount, lockDuration);
    }
}
```

