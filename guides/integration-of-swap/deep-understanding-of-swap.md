# Deep Understanding of Swap

## Swap Logic Breakdown

The token swap logic in the Dyson Pair Contract is divided into two main functions: `_swap0in` and `_swap1in`, corresponding to swapping token0 for token1 and token1 for token0, respectively. Let's focus on the `_swap1in` function to understand the core calculation logic.

#### `_swap1in` Function

`MAX_FEE_RATIO` is set to `2^64` .

```solidity
function _swap1in(uint input, uint minOutput) internal returns (uint fee, uint output) {
    // ... (omitting details for brevity)

    // Fee calculation based on fee ratio for token1
    fee = uint(_feeRatio1) * input / MAX_FEE_RATIO;

    // Adjust input by deducting the fee
    uint inputLessFee = input - fee;

    // Calculate the output using the invariant formula
    output = inputLessFee * reserve0 / (reserve1 + inputLessFee);

    // Ensure the minimum output requirement is met
    require(output >= minOutput, "slippage");

    // Update fee ratio for token0 based on the output proportion of the reserve0w
    uint64 feeRatioAdded = uint64(output * MAX_FEE_RATIO / reserve0);
    _updateFeeRatio1(_feeRatio1, feeRatioAdded);
}
```

1. **Calculate Output:**
   * Obtain the fee ratios, `feeRatio0` and `feeRatio1`, by using the `getFeeRatio()` function. This step updatesd the fee ratios based on the half-life mechanism. When a trade happens, the fee will increase immediately, and decrease as time goes on. The change will keep going until the trading fee reduces to zero.
   * Fee1 calculation based on fee ratio for token1: \
     `fee1 = uint(_feeRatio1) * input / MAX_FEE_RATIO`&#x20;
   * Adjust input by deducting the fee: \
     `inputLessFee = input - fee1`
   * Use the constant product formula `xy = k` to calculate the output: \
     `output = inputLessFee * reserve0 / (reserve1 + inputLessFee)`
2. **Increase `fee0`:**
   * After the swap, to account for changes in the pool ratios and mitigate arbitrage opportunities for liquidity providers, an additional fee (`fee0`) is introduced for the `swap0in` operation.
   * Calculate the added fee0 using: \
     `feeRatioAdded = uint64(MAX_FEE_RATIO * output / reserve0)` \
     This calculation is based on the proportion of the total `token0` in the pool represented by the tokens swapped out during the `_swap0in` operation.
   * Update the fee ratio for `token0` using: \
     `_updateFeeRatio0(_feeRatio0, feeRatioAdded);` \
     This step involves utilizing the formula `newFee = 1 - (1 - x%)(1 - y%)` to calculate the new fee ratio, and the result is stored for future use. About this formula please refer to [Trading Fee Calculation](https://docs.dyson.finance/mechanisms/dynamic-amm#trading-fee-calculation) section in our white paper.

### Conclusion

The Dyson Pair Contract's swap mechanism introduces a dynamic fee model and premium calculation to incentivize users based on their chosen lock times. The core swap logic, exemplified by the `_swap1in` function, showcases the intricacies of fee calculation, input adjustment, and output determination. This approach provides users with a transparent and adaptive swapping experience, aligning incentives with market conditions and user preferences.
