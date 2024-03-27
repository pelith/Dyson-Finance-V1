# Unit Definition

#### DYSON.sol

* decimals is set to be the number `18`
  * ```solidity
    uint8 public constant decimals = 18;
    ```

#### sDYSON.sol

* decimals is set to be the number `18`
  * ```solidity
    uint8 public constant decimals = 18;
    ```
* STAKING\_RATE\_BASE\_UNIT&#x20;
  * <pre class="language-solidity"><code class="lang-solidity"><strong>uint private constant STAKING_RATE_BASE_UNIT = 1e18;
    </strong></code></pre>
  * In the `sDYSON.sol` contract, obtaining the staking rate for staking DYSON in exchange for sDYSON involves adjusting the scale. The staking rate returned by `getStakingRate` is scaled at 1e18, and to correct this scale, it needs to be divided by `STAKING_RATE_BASE_UNIT`. For instance, when calling `getStakingRate` with a lock duration of 86400, the returned value might be `71087213555991969`. To obtain the accurate staking rate, we perform the division: `71087213555991969 / 1e18 = 0.071`. Therefore, the corrected staking rate is `7.1%`.\


#### Farm.sol

* MAX\_AP\_RATIO
  * ```solidity
    int128 private constant MAX_AP_RATIO = 2**64;
    ```
  * When using the `_calcRewardAmount` function in the `Farm` contract, the formula is defined as: `reward = reserve * (1 - 2^(-amount/w))`\
    The result of `2^(-amount/w)` will be scaled in `2**64` because the `exp_2` of `ABDKMath64x64` library is used to execute a binary exponent calculation, which returns the result in a 64.64 fixed point number. Therefore, at this point, we use `MAX_AP_RATIO` instead of `1` to align the scale, resulting in the modified formula:\
    `reward = reserve * (MAX_AP_RATIO - 2^(-amount/w))`\
    This adjustment ensures that the scaling is consistent throughout the calculation.
* BONUS\_BASE\_UNIT
  * <pre class="language-solidity"><code class="lang-solidity"><strong>uint private constant BONUS_BASE_UNIT = 1e18;
    </strong></code></pre>
  * When utilizing the `grantSP` function in the `Farm` contract, the bonus of the user obtained from the `Gauge` contract is scaled in `1e18`, so we use `BONUS_BASE_UNIT` to align the scale during the calculation.

#### Gauge.sol

* REWARD\_RATE\_BASE\_UNIT
  * ```solidity
    uint private constant REWARD_RATE_BASE_UNIT = 1e18;
    ```
  * When utilizing the `newRewardRate` function in the `Gauge` contract, the formula for the new reward rate is defined as follows:\
    `newRewardRate = totalSupply * slope / REWARD_RATE_BASE_UNIT + base;`\
    Because the `totalSupply` and `slope` are scaled in `1e18` , we need to divide the result by `1e18` after the multiplication calculation to maintain the correct scale.

#### Pair.sol & Router.sol

* MAX\_FEE\_RATIO
  * <pre class="language-solidity"><code class="lang-solidity"><strong>uint internal constant MAX_FEE_RATIO = 2**64;
    </strong></code></pre>
  * When utilizing the `calcNewFeeRatio` function in the `Pair` contract, the formula is defined as: `newFeeRatio = oldFeeRatio / 2^(elapsedTime / halfLife)`\
    The result of `2^(elapsedTime / halfLife)` will be scaled in `2**64` because the `exp_2` of `ABDKMath64x64` library is used to execute a binary exponent calculation, which returns the result in a 64.64 fixed point number. It means that the feeRatio is stored in 2\*\*64 scale. Therefore, when we calculate the swap fee in `_swap0in` or `_swap1in` functions, we have to divide the feeRatio by `MAX_FEE_RATIO` to maintain the correct scale.
  * Similarly, when utilizing the `fairPrice` function in the `Router` contract, it applies the same logic as described above.
