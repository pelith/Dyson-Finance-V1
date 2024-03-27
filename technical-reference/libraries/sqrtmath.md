# SqrtMath

The SqrtMath library facilitates fixed-point square root calculations using the Babylonian method.&#x20;

### sqrt

Calculate the square root of an unsigned 256-bit integer using fixed-point arithmetic and the Babylonian method.

```solidity
function sqrt(
    uint256 x) internal pure returns (uint256 z)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="460">Description</th></tr></thead><tbody><tr><td>x</td><td>uint</td><td>Unsigned 256-bit integer for which the square root is calculated.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="463">Description</th></tr></thead><tbody><tr><td>z</td><td>uint</td><td>Unsigned 256-bit integer representing the square root of x.</td></tr></tbody></table>

Numerous instances of the `sqrt` function are employed throughout Dyson Finance, necessitating the calculation of the square root of a uint256 number. This includes various functions within the following contracts:

```solidity
// Gauge.sol
function bonus(address user) external view returns (uint _bonus);
```

```solidity
// Pair.sol
function _grantSP(address to, uint input, uint output, uint premium) internal;
function _withdraw(address from, uint index, address to) internal returns (uint token0Amt, uint token1Amt);
```

```solidity
// Router.sol
function fairPrice(address pair, uint token0Amt) external view returns (uint token1Amt);
```
