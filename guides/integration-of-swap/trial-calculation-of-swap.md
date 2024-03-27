# Trial Calculation of Swap

Before actually making a swap, you'd undoubtedly want to estimate the output of a swap. In this section, we'll walk through the calculations, focusing on this key aspect.

## Concept

In traditional DEXs, we can easily estimate the output by using the formula `x * y = k`, deducting the transaction fee. This helps us determine the ideal minOutput. However, in Dyson Finance, transaction fees are dynamic. Therefore, we first need to obtain the current feeRatio from the Pair contract for subsequent calculations. For more details on the dynamic fee mechanism, you can refer to the [Dynamic AMM](https://docs.dyson.finance/mechanisms/dynamic-amm) section in our white paper.

In essence, in Dyson Finance, a typical swap involves two steps:

1. Deducting a portion from the user's input token as a transaction fee based on the current feeRatio.
2. Using the input after deducting the fee as the actual user input, calculating the output through the formula `x * y = k`.

## Trial Calculation Explanation:

We'll illustrate the above concept using the WETH-USDC Pair as an example.

WETH-USDC Pair (Polygon zkEVM): [`0xEce7244a0e861C841651401fC22cEE577fEE90AF`](https://zkevm.polygonscan.com/address/0xEce7244a0e861C841651401fC22cEE577fEE90AF)

* token0 = WETH
* token1 = USDC

Let's perform a swap1in by calling the function with 1000 USDC. How do we calculate the resulting output in ETH?

```solidity
function swap1in(address to, uint input, uint minOutput) external lock returns (uint output)
```

1.  Obtain the current feeRatio using WETH-USDC Pair's `getFeeRatio`. Note that the obtained feeRatio will be between 0 and MAX\_FEE\_RATIO (2^64).

    * \_feeRatio0: 118336540955861214
    * \_feeRatio1: 117561845007685430

    <div align="left">

    <figure><img src="../../.gitbook/assets/image (21).png" alt=""><figcaption></figcaption></figure>

    </div>
2.  Get the current reserves using WETH-USDC Pair's `getReserves`:

    * reserve0: 26681664208917997641
    * reserve1: 65319923022

    <div align="left">

    <figure><img src="../../.gitbook/assets/image (22).png" alt=""><figcaption></figcaption></figure>

    </div>
3. Calculate the transaction fee: `fee = input * feeRatio1 / MAX_FEE_RATIO`
   * fee = 1000e6 \* 117561845007685430 / 2^64 = <mark style="color:red;">`6373040.38794`</mark>
4. The actual input after deducting the fee: `realInput = input - fee`
   * realInput = 1000e6 - 6373040.38794 = <mark style="color:red;">`993626959.612`</mark>
5.  Use the formula x \* y = k to calculate the output:

    `output = realInput * reserve0 / (reserve1 + realInput)`

    * output = 993626959.612 \* 26681664208917997641 / (65319923022 + 993626959.612) = <mark style="color:red;">`0.39979191e18`</mark>

Calculation Result: We can buy approximately 0.39979191 ETH with 1000 USDC. The average buying price for 1 ETH is 2501.3 USDC.

By performing the above calculations, we can determine the output of a swap and set the ideal minOutput accordingly.

## Implement

WETH-USDC Pair (Polygon zkEVM): [`0xEce7244a0e861C841651401fC22cEE577fEE90AF`](https://zkevm.polygonscan.com/address/0xEce7244a0e861C841651401fC22cEE577fEE90AF)

* token0 = WETH
* token1 = USDC

```solidity
pragma solidity 0.8.17;

interface IPair {
    function getReserves() external view returns (uint reserve0, uint reserve1);
    function getFeeRatio() external view returns (uint64 _feeRatio0, uint64 _feeRatio1);
}

contract VirtualSwap {
    uint constant MAX_FEE_RATIO = 2**64;
    address pair = 0xEce7244a0e861C841651401fC22cEE577fEE90AF;

    function virtualSwap0in(uint input) internal view returns (uint output) {
        (uint reserve0, uint reserve1) = IPair(pair).getReserves();
        (uint64 _feeRatio0, ) = IPair(pair).getFeeRatio();
        uint fee = uint(_feeRatio0) * input / MAX_FEE_RATIO;
        uint inputLessFee = input - fee;
        output = inputLessFee * reserve1 / (reserve0 + inputLessFee);
    }

    function virtualSwap1in(uint input) internal view returns (uint output) {
        (uint reserve0, uint reserve1) = IPair(pair).getReserves();
        (, uint64 _feeRatio1) = IPair(pair).getFeeRatio();
        uint fee = uint(_feeRatio1) * input / MAX_FEE_RATIO;
        uint inputLessFee = input - fee;
        output = inputLessFee * reserve0 / (reserve1 + inputLessFee);
    }

}
```

To calculate the output value of your swap, you can call

`virtualSwap0in` or `virtualSwap1in` . For example:

```solidity
contract MyTest {
    function run() external {
        address virtualSwap = 0x....; // Deploy the VirtualSwap contract
        uint input0 = 10e18; // 10 WETH
        uint output = VirtualSwap(virtualSwap).virtualSwap0in(input0);
    }
}
```

The `output` is the output of your swap.
