---
description: The ABDKMath64x64 library provides fixed-point arithmetic operations.
---

# ABDKMath64x64

### mulu

Calculate `x * y` rounding down, where `x` is a signed 64.64 fixed-point number, and `y` is an unsigned 256-bit integer. Revert on overflow.

```solidity
function mulu (
    int128 x, 
    uint256 y) internal pure returns (uint256)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>x</td><td>int128</td><td>Signed 64.64 fixed-point number.</td></tr><tr><td>y</td><td>uint</td><td>Unsigned 256-bit integer.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>None</td><td>uint</td><td>Unsigned 256-bit integer.</td></tr></tbody></table>

### divu

Calculate `x / y` rounding towards zero, where `x` and `y` are unsigned 256-bit integer numbers. Revert on overflow or when `y` is zero.

```solidity
function divu (
    uint256 x, 
    uint256 y) internal pure returns (int128)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>x</td><td>uint</td><td>Unsigned 256-bit integer.</td></tr><tr><td>y</td><td>uint</td><td>Unsigned 256-bit integer.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>None</td><td>int128</td><td>Signed 64.64 fixed-point number.</td></tr></tbody></table>

### exp\_2

The `exp_2` function calculates the binary exponent of a given signed 64.64-bit fixed-point number, `x`. This function utilizes a series of conditional multiplications based on the bits set in the binary representation of `x`. The purpose is to efficiently approximate the value of `2^x` without resorting to iterative calculations, ensuring that the result is a signed 64.64-bit fixed-point number.

```solidity
function exp_2 (
    int128 x) internal pure returns (int128)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>x</td><td>int128</td><td>Signed 64.64 fixed-point number.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>None</td><td>int128</td><td>Signed 64.64 fixed-point number.</td></tr></tbody></table>

### divuu

Internal function to calculate x / y rounding towards zero, where x and y are unsigned 256-bit integer numbers. Revert on overflow or when y is zero.

This function is designed to provide a robust and efficient method for dividing two `uint256` numbers in a way that accounts for various scenarios, including large numbers and potential overflow issues. The approach combines bit manipulation, conditional statements, and explicit checks to balance performance and accuracy.

```solidity
function divuu (
    uint256 x, 
    uint256 y) private pure returns (uint128)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>x</td><td>uint</td><td>Unsigned 256-bit integer.</td></tr><tr><td>y</td><td>uint</td><td>Unsigned 256-bit integer.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="342">Description</th></tr></thead><tbody><tr><td>None</td><td>uint128</td><td>Unsigned 64.64 fixed-point number.</td></tr></tbody></table>



This library plays a pivotal role in Dyson Finance, notably in the `divu` and `exp_2` functions, which are extensively employed. These functions are integral to several critical calculations within various contracts:

```solidity
// Farm.sol
function _calcRewardAmount(uint _reserve, uint _amount, uint _w) internal pure returns (uint reward)
```

```solidity
// Pair.sol
function calcNewFeeRatio(uint64 _oldFeeRatio, uint _elapsedTime) public view returns (uint64 _newFeeRatio)
```

<pre class="language-solidity"><code class="lang-solidity"><strong>// sDYSON.sol
</strong><strong>function stakingRate(uint lockDuration) external view returns (uint rate)
</strong></code></pre>
