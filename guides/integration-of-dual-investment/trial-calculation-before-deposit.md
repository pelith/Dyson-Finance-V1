# Trial Calculation before deposit

Before actually making a deposit, you'd undoubtedly want to estimate how much premium the investment could yield, the settlement price at maturity, and the additional $DYSN rewards you might receive. In this section, we'll walk through the calculations, focusing on three key aspects:

1. **How to calculate the premium and the strike price used for settlement of a Dual-Investment position.**
2. **How to compute the discounted value of a Dual-Investment position before maturity.**
3. **How to determine the type of assets (token0 or token1) redeemable after the maturity of a Dual-Investment position.**
4. **How to calculate the extra DYSN rewards obtained from a dual-currency transaction.**

We'll illustrate these concepts using the WETH-USDC Pair as an example.

WETH-USDC Pair (Polygon zkEVM): [`0xEce7244a0e861C841651401fC22cEE577fEE90AF`](https://zkevm.polygonscan.com/address/0xEce7244a0e861C841651401fC22cEE577fEE90AF)

* token0 = WETH
* token1 = USDC

## Calculation of Premium & Strike Price

### Premium

As the assets stay locked in a pool for a longer duration, investors can expect higher returns. The premium calculation is outlined by the formula below:

![](<../../.gitbook/assets/image (4).png>)

For details on the premium calculation mechanism, kindly consult the [_Dual Investment Premium calculation_](https://docs.dyson.finance/mechanisms/dual-investment#premium-calculation) section in our white paper.&#x20;

The `PremiumCalculator` Presented here is a Solidity smart contract that enables you to pre-calculate the principal plus interest based on your input and lock time, providing an overview before making an actual deposit within the pair.

```solidity
pragma solidity 0.8.17;

interface IPair {
    function getPremium(uint time) external view returns (uint premium);
    function getReserves() external view returns (uint reserve0, uint reserve1);
    function getFeeRatio() external view returns (uint64 _feeRatio0, uint64 _feeRatio1);
}

contract PremiumCalculator {
    uint constant MAX_FEE_RATIO = 2**64;
    uint constant PREMIUM_BASE_UNIT = 1e18;
    address pair = 0xEce7244a0e861C841651401fC22cEE577fEE90AF; // WETH-USDC Pair contract on Polygon zkEVM

    function calculateDeposit0Premium(uint input, uint time) external view returns (uint token0AmtWithPremium, uint token1AmtWithPremium) {
        uint premium = IPair(pair).getPremium(time);
        uint output = virtualSwap0in(input);
        (token0AmtWithPremium, token1AmtWithPremium) = calculatePremium(input, output, premium);
    }

    function calculateDeposit1Premium(uint input, uint time) external view returns (uint token0AmtWithPremium, uint token1AmtWithPremium) {
        uint premium = IPair(pair).getPremium(time);
        uint output = virtualSwap1in(input);
        (token0AmtWithPremium, token1AmtWithPremium) = calculatePremium(output, input, premium);
    }

    function calculatePremium(uint token0Amt, uint token1Amt, uint premium) internal pure returns (uint token0AmtWithPremium, uint token1AmtWithPremium){
        token0AmtWithPremium = token0Amt * (premium + PREMIUM_BASE_UNIT) / PREMIUM_BASE_UNIT;
        token1AmtWithPremium = token1Amt * (premium + PREMIUM_BASE_UNIT) / PREMIUM_BASE_UNIT;
    }

    function virtualSwap0in(uint input) public view returns (uint output) {
        (uint reserve0, uint reserve1) = IPair(pair).getReserves();
        (uint64 _feeRatio0, ) = IPair(pair).getFeeRatio();
        uint fee = uint(_feeRatio0) * input / MAX_FEE_RATIO;
        uint inputLessFee = input - fee;
        output = inputLessFee * reserve1 / (reserve0 + inputLessFee);
    }

    function virtualSwap1in(uint input) public view returns (uint output) {
        (uint reserve0, uint reserve1) = IPair(pair).getReserves();
        (, uint64 _feeRatio1) = IPair(pair).getFeeRatio();
        uint fee = uint(_feeRatio1) * input / MAX_FEE_RATIO;
        uint inputLessFee = input - fee;
        output = inputLessFee * reserve0 / (reserve1 + inputLessFee);
    }
}
```

To determine the amounts of token and token1 you'll receive after maturity, you can invoke the functions `calculateDeposit0Premium` and `calculateDeposit1Premium`. For instance:

```solidity
contract MyTest {
    function run() external {
        address calculator = 0x....; // Deploy the PremiumCalculator contract
        uint input0 = 10e18; // 10 WETH
        uint time = 1 days;
        (uint token0AmtWithPremium, uint token1AmtWithPremium) = PremiumCalculator(calculator).calculateDeposit0Premium(input0, time);
    }
}
```

The `token0AmtWithPremium` and `token1AmtWithPremium` represent the principal plus interest of token0 and token1. The choice of which token you can redeem will be determined by the fair price at maturity.

### Strike Price

Continuing from the previous section, you can directly compute the Strike Price using the following formula:

`Strike Price= token1AmtWithPremium / token0AmtWithPremium ​`

When investors redeem, if the fair price surpasses the strike price, they will receive `token1AmtWithPremium` of token1. Conversely, if the fair price is lower, they will obtain `token0AmtWithPremium` of token0. About the details of fair price, please refer to [_fair price_](https://docs.dyson.finance/mechanisms/dual-investment#fair-price) section in our white paper.

## The discounted value of your position prior to maturity

First and foremost, it's essential to clarify that the discounted value serves as a reference for estimating the value of your position. The actual redemption of the position can only occur after reaching maturity.

The redeemable fund after maturity will be `token0Amt` or `token1Amt` which is calculated in Strike Price, the calculation of the discounted value before the maturity please refer to the below formulas:

<figure><img src="../../.gitbook/assets/image (5).png" alt="" width="375"><figcaption><p>Calculation of the discounted value before the maturity</p></figcaption></figure>

**time** refers to the **remaining time** until the position's maturity.&#x20;

Based on the formula above, we can calculate the discounted value of our position prior maturity. Below is the smart contract which demonstrates the calculation:

```solidity
pragma solidity 0.8.17;

interface IPair {
    function basis() external view returns (uint);
}

interface IPremiumCalculator {
    function calculateDeposit0Premium(uint input, uint time) external view returns (uint token0AmtWithPremium, uint token1AmtWithPremium);
    function calculateDeposit1Premium(uint input, uint time) external view returns (uint token0AmtWithPremium, uint token1AmtWithPremium);
}

// https://github.com/Gaussian-Process/solidity-sqrt/blob/main/src/FixedPointMathLib.sol
library SqrtMath {
    function sqrt(uint256 x) internal pure returns (uint256 z) {
        ...
    }
}

contract DiscountedValueCalculator {
    using SqrtMath for *;
    address pair = 0xEce7244a0e861C841651401fC22cEE577fEE90AF; // WETH-USDC Pair on Polygon zkEVM
    address premiumCalculator = 0x....; // Deploy the PremiumCalculator contract

    /** 
    // @param input Amount of token0 to deposit
    // @param totalLockTime Total lock time in seconds
    // @param timeRemaining Time remaining prior maturity in days
    */
    function calculateDeposit0DiscountedValue(uint input, uint totalLockTime, uint timeRemaining) public view returns (uint token0DiscountedValue, uint token1DiscountedValue) {
        uint discountedPremium = getDiscountedPremium(timeRemaining);

        // Calculate discounted value = token0AmtWithPremium / discounted premium
        (uint token0AmtWithPremium, uint token1AmtWithPremium) = IPremiumCalculator(premiumCalculator).calculateDeposit0Premium(input, totalLockTime);
        token0DiscountedValue = token0AmtWithPremium / discountedPremium;
        token1DiscountedValue = token1AmtWithPremium / discountedPremium;
    }

    /** 
    // @param input Amount of token0 to deposit
    // @param totalLockTime Total lock time in seconds
    // @param timeRemaining Time remaining prior maturity in days
    */
    function calculateDeposit1DiscountedValue(uint input, uint totalLockTime, uint timeRemaining) public view returns (uint token0DiscountedValue, uint token1DiscountedValue) {
        uint discountedPremium = getDiscountedPremium(timeRemaining);

        // Calculate discounted value = token0AmtWithPremium / discounted premium
        (uint token0AmtWithPremium, uint token1AmtWithPremium) = IPremiumCalculator(premiumCalculator).calculateDeposit1Premium(input, totalLockTime);
        token0DiscountedValue = token0AmtWithPremium / discountedPremium;
        token1DiscountedValue = token1AmtWithPremium / discountedPremium;
    }

    /** 
    // @param timeRemaining Time remaining prior maturity in days
    */
    function getDiscountedPremium(uint timeRemaining) internal view returns (uint discountedPremium) {
        uint basis = IPair(pair).basis(); // basis in WETH-USDC pair currently is set to 0.7e18
        
        // Calculate discounted premium = 1 + basis * 0.4 * sqrt(timeRemaining/365). 
        // The discountedPremium will be scaled in 1e18
        discountedPremium = 1e18 + basis * 0.4e18 * (timeRemaining * 1e36 / 365).sqrt() / 1e36;
    }
}

```

To calculate the discounted value of your position, you can call

`calculateDeposit0DiscountedValue` or `calculateDeposit1DiscountedValue` .&#x20;

For example:

```solidity
contract MyTest {
    function run() external {
        address calculator = 0x....; // Deploy the DiscountedValueCalculator contract
        uint input0 = 10e18; // 10 WETH
        uint totalLockTime = 30 days;
        uint timeRemaining = 1 days;
        (uint token0DiscountedValue, uint token1DiscountedValue) = DiscountedValueCalculator(calculator).calculateDeposit0DiscountedValue(input0, totalLockTime, timeRemaining);
    }
}
```

The `token0DiscountedValue` and `token1DiscountedValue` are the discounted value of token0 and token1.

## Determining Token Redemption at Position Maturity

After maturity, the redeemable fund will consist of either `token0Amt` or `token1Amt`. The system's decision on which token users can redeem depends on the Strike Price and Fair Price at the maturity date. If, during redemption, the fair price surpasses the strike price, investors will receive `token1Amt` of token1. Conversely, if the fair price is lower than the strike price, they will receive `token0Amt` of token0.

<div align="center">

<figure><img src="../../.gitbook/assets/image (6).png" alt="" width="263"><figcaption><p>Strike Price Formula</p></figcaption></figure>

</div>

<div align="center">

<figure><img src="../../.gitbook/assets/image (7).png" alt="" width="329"><figcaption><p>Fair Price Formula</p></figcaption></figure>

</div>

Comparing the formula above, we can express it as follows:

<figure><img src="../../.gitbook/assets/image (3).png" alt="" width="375"><figcaption><p>Compare the size to decide which token can be redeemed</p></figcaption></figure>

Upon maturity, we can utilize the above formula, incorporating the current state of pools, to determine which token can be redeemed. In Solidity code, this can be implemented as follows:

```solidity
pragma solidity 0.8.17;

interface IPair {
    function getReserves() external view returns (uint reserve0, uint reserve1);
    function getFeeRatio() external view returns (uint64 _feeRatio0, uint64 _feeRatio1);
}

interface IPremiumCalculator {
    function calculateDeposit0Premium(uint input, uint time) external view returns (uint token0AmtWithPremium, uint token1AmtWithPremium);
    function calculateDeposit1Premium(uint input, uint time) external view returns (uint token0AmtWithPremium, uint token1AmtWithPremium);
}
// https://github.com/Gaussian-Process/solidity-sqrt/blob/main/src/FixedPointMathLib.sol
library SqrtMath {
    function sqrt(uint256 x) internal pure returns (uint256 z) {
        ...
    }
}

contract DecisionMaker {
    using SqrtMath for *;
    uint constant MAX_FEE_RATIO = 2**64;
    /// @dev Square root of `MAX_FEE_RATIO`
    uint constant MAX_FEE_RATIO_SQRT = 2**32;
    address pair = 0xEce7244a0e861C841651401fC22cEE577fEE90AF; // WETH-USDC Pair on Polygon zkEVM
    address premiumCalculator = 0x....; // Deploy the PremiumCalculator contract
    
    function decide(bool isDepositToken0, uint input, uint time) public view returns (bool isReturnToken0) {
        (uint64 _feeRatio0, uint64 _feeRatio1) = IPair(pair).getFeeRatio();
        (uint reserve0, uint reserve1) = IPair(pair).getReserves();
        
        uint token0Amt;
        uint token1Amt;

        if (isDepositToken0) {
            (token0Amt, token1Amt) = IPremiumCalculator(premiumCalculator).calculateDeposit0Premium(input, time);
        } else {
            (token0Amt, token1Amt) = IPremiumCalculator(premiumCalculator).calculateDeposit1Premium(input, time);
        }
        
        /* Formula to determine which token to withdraw:
        // `token0Amt` * sqrt(1 - feeRatio0) / reserve0 < `token1Amt` * sqrt(1 - feeRatio1) / reserve1
        // The formula can be transformed to:
        // sqrt((1 - feeRatio0)/(1 - feeRatio1)) * `token0Amt` / reserve0 < `token1Amt` / reserve1
        */
        if((MAX_FEE_RATIO * (MAX_FEE_RATIO - uint(_feeRatio0)) / (MAX_FEE_RATIO - uint(_feeRatio1))).sqrt() * token0Amt / reserve0 < MAX_FEE_RATIO_SQRT * token1Amt / reserve1) {
            // user redeem token0
            return true;
        }
        else {
            // user redeem token1
            return false;
        }
    }
}
```

Upon maturity, you can invoke the `decide` function to ascertain which token is eligible for redemption. This determination relies on the prevailing pool conditions, including reserves and fee ratios.

```solidity
contract MyTest {
    function run() external {
        address maker = 0x....; // Deploy the DecisionMaker contract
        uint input0 = 10e18; // 10 WETH
        uint time = 30 days;
        bool isRedeemToken0 = DecisionMaker(maker).decide(true, input, time);
    }
}
```

### How to Calculate Additional DYSN Rewards in a Dual Investment

Investing in Dual Investment on Dyson Finance allows Dyson members to instantly receive Points, which can later be converted to $DYSN. Below is the flow of conversion process.

About membership, please refer to [_Membership_](https://docs.dyson.finance/mechanisms/token-incentive/membership) section in our white paper.

#### Convert flow:

*   Dual Investment -> localPoint

    <div align="left">

    <figure><img src="../../.gitbook/assets/image (23).png" alt="" width="375"><figcaption></figcaption></figure>

    </div>
*   #### localPoint -> Point

    <div align="left">

    <figure><img src="../../.gitbook/assets/image (24).png" alt="" width="375"><figcaption></figcaption></figure>

    </div>
*   Point -> $DYSN

    <div align="left">

    <figure><img src="../../.gitbook/assets/image (25).png" alt="" width="375"><figcaption></figcaption></figure>

    </div>

The `DysonRewardCalculator` contract showcases the calculation for converting a local point generated through dual investment into $DYSN rewards.

```solidity
pragma solidity 0.8.17;

interface IPair {
    function getPremium(uint time) external view returns (uint premium);
}

interface IFarm {
    function pools(address poolId) external view returns (uint weight, uint rewardRate, uint lastUpdateTime, uint lastReserve, address gauge);
    function globalPool() external view returns (uint weight, uint rewardRate, uint lastUpdateTime, uint lastReserve, address gauge);
    function getCurrentPoolReserve(address poolId) view external returns (uint reserve);
    function getCurrentGlobalReserve() view external returns (uint reserve);
}

interface IGauge {
    function bonus(address user) external view returns (uint _bonus);
}
// https://github.com/DysonFinance/Dyson-Finance-V1/blob/main/src/lib/ABDKMath64x64.sol
library ABDKMath64x64 {
    function mulu (int128 x, uint256 y) internal pure returns (uint256) {
        ...
    }
    function divu (uint256 x, uint256 y) internal pure returns (int128) {
        ...
    }
    function exp_2 (int128 x) internal pure returns (int128) {
        ...
    }
}

//https://github.com/Gaussian-Process/solidity-sqrt/blob/main/src/FixedPointMathLib.sol
library SqrtMath {
    function sqrt(uint256 x) internal pure returns (uint256 z) {
        ...
    }
}

contract DysonRewardCalculator {
    using ABDKMath64x64 for *;
    using SqrtMath for *;
    uint constant PREMIUM_BASE_UNIT = 1e18;
    uint constant BONUS_BASE_UNIT = 1e18;
    int128 constant MAX_POINT_RATIO = 2**64;

    address pair = 0xEce7244a0e861C841651401fC22cEE577fEE90AF; // WETH-USDC Pair on Polygon zkEVM
    address farm = 0x746a40964c406B0c402a98Cf60081d22621227fd; // Dyson Farm on Polygon zkEVM

    /**
     * @dev Calculate the reward amount for a given dual investment position
     * @param to The position owner
     * @param input The input amount
     * @param output The output amount
     * @return dysonReward reward amount
     */
    function calculateDysonReward(address to, uint input, uint output, uint time) public view returns (uint dysonReward) {
        uint premium = IPair(pair).getPremium(time);
        (uint localWeight,,,, address gauge) = IFarm(farm).pools(pair);
        
        uint localPoint = (input * output).sqrt() * premium / PREMIUM_BASE_UNIT;

        // check pool boosting
        uint boosting = IGauge(gauge).bonus(to);
        if (boosting > 0) localPoint = localPoint * (boosting + BONUS_BASE_UNIT) / BONUS_BASE_UNIT;
        
        // swap localPoint to Point
        uint localReserve = IFarm(farm).getCurrentPoolReserve(pair);
        uint point = calcRewardAmount(localReserve, localPoint, localWeight);

        // swap Point to $DYSN
        uint globalReserve = IFarm(farm).getCurrentGlobalReserve();
        (uint globalWeight,,,,) = IFarm(farm).globalPool();
        dysonReward = calcRewardAmount(globalReserve, point, globalWeight);
    }

    function calcRewardAmount(uint _reserve, uint _amount, uint _w) internal pure returns (uint reward) {
        int128 r = _amount.divu(_w);
        int128 e = (-r).exp_2();
        reward = (MAX_POINT_RATIO - e).mulu(_reserve);
    }

}
```

To determine the $DYSN reward generated from a dual investment, you can make use of the `PremiumCalculator` and `DysonRewardCalculator` contracts. These contracts facilitate the calculation of rewards based on the lock time and input amount in the dual investment.

```solidity
contract MyTest {
    function run() external {
        address calculator = 0x....; // Deploy the DysonRewardCalculator contract
        address premiumCalculator = 0x...; // Deploy the PremiumCalculator contract
        uint input0 = 10e18; // 10 WETH
        uint time = 30 days;
        uint output1 = PremiumCalculator(premiumCalculator).virtualSwap0in(input0);
        uint dysonReward = DysonRewardCalculator(calculator).calculateDysonReward(to, input0, output1, time);
    }
}
```

The `dysonReward` is the $DYSN reward of your dual investment position.
