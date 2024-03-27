# Perfrom a Dual Investment Deposit

## Executing a Dual Investment Deposit: Two Approaches&#x20;

There are two methods available for initiating a deposit, each with its own distinct advantages. The first method involves direct interaction with the Pair contract, while the second utilizes the Router contract. The primary distinction lies in the fact that the second method can facilitate the depositing of ETH, wherein the Router converts ETH to WETH before executing the actual deposit. This section will provide guidance on both options.

### 1. Direct Deposit within Pair Contract&#x20;

Within the Pair contract, you'll encounter the following two functions. You have the flexibility to select the token for depositing, be it token0 or token1, and proceed with the deposit. Note that each depositor will receive a `note` as unique identifier, serving as a recognition of identity for subsequent withdrawal processes.

```solidity
// Pair.sol
function deposit0(
    address to, 
    uint input, 
    uint minOutput, 
    uint time) external lock returns (uint output)

function deposit1(
    address to, 
    uint input, 
    uint minOutput, 
    uint time) external lock returns (uint output)
```

Parameters:

* `to` : Address that owns the note.
* `input` : Amount of token to deposit.
* `minOutput` : Minimum amount of token expected to receive. If the swap is performed, the depositor will obtain the token different from the one initially provided as input.
* `time` : Lock time. It can be either 1 day, 3 days, 7 days or 30 days.

Return Value:

* `output` : Amount of token1 received if the swap is performed.

#### Set Up your  Contract

* Declare the solidity version used to compile the contract.
* Import the pair interface and IERC20 interface.
* Write your own contract, here we name it `MyDepositTest`. Remember that the caller must `approve` the contract to withdraw the tokens from the calling address's account to execute a swap.

<pre class="language-solidity"><code class="lang-solidity">// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
<strong>
</strong>interface IPair {
    function deposit0(address to, uint input, uint minOutput, uint time) external returns (uint output);
    function deposit1(address to, uint input, uint minOutput, uint time) external returns (uint output);
}

interface IERC20 {
    function approve(address spender, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract MyDepositTest {
    // The DYSON-USDC pair contract on Polygon zkEVM. 
    // In this pair, the token0 represents $DYSN and token1 represents $USDC.
    address dysonUsdcPair = 0xC9001AFF3701e19C29E996D48e474Baf4C5eD006;
    // The $DYSN contract on Polygon zkEVM.
    address public constant DYSN = 0x9CBD81b43ba263ca894178366Cfb89A246D1159C;
    // The $USDC contract on Polygon zkEVM.
    address public constant USDC = 0xA8CE8aee21bC2A48a5EF670afCc9274C7bbbC035;
    
    address to = address(this);
    uint lockTime = 1 days; // Deposit for 1 day
    
    // assume that 1 $DYSN = 1 $USDC
    uint dysonIn = 100e18; // 100 $DYSN
    uint minUSDCOut = 90e6; // Slippage = 10%
    
    uint usdcIn = 100e6; // 100 $USDC
    uint minDysonOut = 90e18 // Slippage = 10%
    
    function depositDYSN() external returns (uint output) {
        IERC20(DYSN).transferFrom(msg.sender, address(this), dysonIn)
        IERC20(DYSN).approve(dysonUsdcPair, dysonIn);
        return IPair(dysonUsdcPair).deposit0(to, dysonIn, minUSDCOut, lockTime);
    }
    
    function depositUSDC() external returns (uint output) {
        IERC20(USDC).transferFrom(msg.sender, address(this), usdcIn)
        IERC20(USDC).approve(dysonUsdcPair, usdcIn);
        return IPair(dysonUsdcPair).deposit1(to, usdcIn, minDysonOut, lockTime);
    }
}
</code></pre>

### 2. Deposit through Router Contract&#x20;

Alternatively, you can execute a deposit through the Router contract. You can initiate a deposit using the function below within the Router contract.

```solidity
// Router.sol
function deposit(
    address tokenIn, 
    address tokenOut, 
    uint index, 
    address to, 
    uint input, 
    uint minOutput, 
    uint time) external returns (uint output)
```

Parameters:

* `tokenIn` : Address of the spent token.
* `tokenOut` : Address of the received token.
* `index` : Number of the pair instance.
* `to` : Address that will receive Pair note.
* `input` : Amount of tokenIn to deposit.
* `minOutput` : Minimum amount of tokenOut expected if the swap is performed.
* `time` : Lock time for the deposit. It can be either 1 day, 3 days, 7 days or 30 days.

Return Value:

* `output` : Amount of tokenOut received if the swap is performed.

In the case of depositing ETH, you can use the function below.

```solidity
// Router.sol
function depositETH(
    address tokenOut, 
    uint index, 
    address to, 
    uint minOutput, 
    uint time) external payable returns (uint output)
```

Parameters:

* `tokenOut` : Address of the received token.
* `index` : Number of the pair instance.
* `to` : Address that will receive Pair note.
* `minOutput` : Minimum amount of tokenOut expected if the swap is performed.
* `time` : Lock time for the deposit. It can be either 1 day, 3 days, 7 days or 30 days.

Return Value:

* `output` : Amount of tokenOut received if the swap is performed.

#### Set Up your Contract

* Declare the solidity version used to compile the contract.
* Import IRouter interface and IERC20 interface.
* Write your own contract. Remember that the caller must `approve` the contract to withdraw the tokens from the calling address's account to execute a swap.

```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

interface IRouter {
    function deposit(address tokenIn, address tokenOut, uint index, address to, uint input, uint minOutput, uint time) external returns (uint output);
    function depositETH(address tokenOut, uint index, address to, uint minOutput, uint time) external payable returns (uint output);
}

interface IERC20 {
    function approve(address spender, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract MyDepositTest {
    // The Router contract on Polygon zkEVM.
    address public constant router = 0xADa6e69781399990d42bEcB1a9427955FFA73Bdc;
    // The $DYSN contract on Polygon zkEVM.
    address public constant DYSN = 0x9CBD81b43ba263ca894178366Cfb89A246D1159C;
    // The $USDC contract on Polygon zkEVM.
    address public constant USDC = 0xA8CE8aee21bC2A48a5EF670afCc9274C7bbbC035;
    
    function depositDYSN(uint index, address to, uint input, uint minOutput, uint time) external returns (uint output) {
        IERC20(DYSN).transferFrom(msg.sender, address(this), amountIn)
        IERC20(DYSN).approve(router, amountIn);
        IRouter(router).deposit(DYSN, USDC, index, to, input, minOutput, time);
    }
    
    function depositUSDC(uint index, address to, uint input, uint minOutput, uint time) external returns (uint output) {
        IERC20(USDC).transferFrom(msg.sender, address(this), amountIn)
        IERC20(USDC).approve(router, amountIn);
        IRouter(router).deposit(USDC, DYSN, index, to, input, minOutput, time);
    }
    
    // Ensure this contract has enough ETH before performing `depositETH`.
    function depositETH(uint depositAmount, address to, uint index, uint minOutput, uint time) external payable returns (uint output) {
        return IRouter(router).depositETH{value: depositAmount}(USDC, index, to, minOutput, time);
    }
}
```
