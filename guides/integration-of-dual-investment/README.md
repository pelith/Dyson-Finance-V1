# Integration of Dual Investment

We assume you're comparing the returns of dual investment between Dyson Finance and other protocols. If Dyson Finance offers superior profits, you might consider making an actual deposit. This guide consists of two sections to assist you in these tasks:

1. **Trial Calculation for Expected Returns:**
2. **Executing a Dual Investment Deposit:**

## Concept of Deposit & Withdraw

If you're not familiar with dual investment in Dyson Finance, we recommend checking out the [_Dual Investment_](https://docs.dyson.finance/mechanisms/dual-investment) section in the white paper first.

When engaging in dual investment on Dyson Finance, you'll use the `deposit0` or `deposit1` functions within the Pair contract.&#x20;

```solidity
function deposit0(address to, uint input, uint minOutput, uint time) external lock returns (uint output);
function deposit1(address to, uint input, uint minOutput, uint time) external lock returns (uint output);
```

Let's take `deposit0` as an example. Here's how the process unfolds:

1. Based on the provided input, the current feeRatio, and pool reserves, a simulated swap is executed to determine the output.
2. The corresponding premium is calculated according to the specified lock-up time.
3. Information such as input, output, time, premium, etc., is recorded in a note and stored in the contract variables.
4. If the depositor is a Dyson member, the system instantly generates point rewards for this deposit.

As the expiration date of this note approaches, users can redeem it by calling the `withdraw` function in the Pair contract.

```solidity
function withdraw(uint index, address to) external lock returns (uint token0Amt, uint token1Amt)
```

The `withdraw` function proceeds as follows:

1. It calculates the strike price and fair price, then compares the two.
2. Based on the comparison result, it determines which asset the user can redeem.
