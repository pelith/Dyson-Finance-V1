# Perform a Swap

## Executing a Swap: Two Approaches&#x20;

There are two methods available for initiating a swap, each with its own distinct advantages. The first method involves direct interaction with the Pair contract, while the second utilizes the Router contract. The primary distinction lies in the fact that the second method can facilitate the swapping of ETH, wherein the Router converts ETH to WETH before executing the actual swap. This section will provide guidance on both options.

### 1. Direct Swap within Pair Contract&#x20;

Within the Pair contract, you'll encounter the following two functions. You have the flexibility to select the token for swapping, be it token0 or token1, and proceed with the swap.

```solidity
// Pair.sol
function swap0in(
    address to, 
    uint input, 
    uint minOutput) external lock returns (uint output)

function swap1in(
    address to, 
    uint input, 
    uint minOutput) external lock returns (uint output)
```

Parameters:

* `to` : Address to receive swapped token.
* `input` : Amount of token to swap.
* `minOutput` : Minimum amount of token expected to receive.

Return Value:

* `output` : Amount of token swapped.

#### Set Up your Contract

1. Declare the solidity version used to compile the contract.
2. Import the pair interface and IERC20 interface.
3. Write your own contract, here we name it `MySwapTest`. Remember that the caller must `approve` the contract to withdraw the tokens from the calling address's account to execute a swap.

<pre class="language-solidity"><code class="lang-solidity">// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
<strong>
</strong>interface IPair {
    function swap0in(address to, uint input, uint minOutput) external returns (uint output);
    function swap1in(address to, uint input, uint minOutput) external returns (uint output);
}

interface IERC20 {
    function approve(address spender, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract MySwapTest {
    // The DYSON-USDC pair contract on Polygon zkEVM. 
    // In this pair, the token0 represents $DYSN and token1 represents $USDC.
    address dysonUsdcPair = 0xC9001AFF3701e19C29E996D48e474Baf4C5eD006;
    // The $DYSN contract on Polygon zkEVM.
    address public constant DYSN = 0x9CBD81b43ba263ca894178366Cfb89A246D1159C;
    // The $USDC contract on Polygon zkEVM.
    address public constant USDC = 0xA8CE8aee21bC2A48a5EF670afCc9274C7bbbC035;
    
    address to = address(this);
    // assume that 1 $DYSN = 1 $USDC
    uint dysonIn = 100e18; // 100 $DYSN
    uint minUSDCOut = 90e6; // Slippage = 10%
    
    uint usdcIn = 100e6; // 100 $USDC
    uint minDysonOut = 90e18 // Slippage = 10%
    
    // Make sure caller wallet has enough $DYSN
    function swapDYSNIn() external returns (uint output) {
        IERC20(DYSN).transferFrom(msg.sender, address(this), dysonIn)
        IERC20(DYSN).approve(dysonUsdcPair, dysonIn);
        return IPair(dysonUsdcPair).swap0in(to, dysonIn, minUSDCOut);
    }
    
    // Make sure caller wallet has enough $USDC
    function swapUSDCIn() external returns (uint output) {
        IERC20(USDC).transferFrom(msg.sender, address(this), usdcIn)
        IERC20(USDC).approve(dysonUsdcPair, usdcIn);
        return IPair(dysonUsdcPair).swap1in(to, usdcIn, 90e18);
    }
}
</code></pre>

#### Token0 and Token1, which is which?

The table presented below outlines the corresponding relationship. Specifically, concerning the Polygon zkEVM, token0 represents $DYSN, and token1 represents $USDC within the DYSON-USDC pair. The order is determined based on the address size, as follows:

```solidity
// Factory.sol
function createPair(address tokenA, address tokenB) external returns (address pair) {
    // ...
    (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    // ...
}
```

Verification of this information can also be done through Blockchain Explorer, including [Polygonscan](https://zkevm.polygonscan.com/) and [Lineascan](https://lineascan.build/).

Polygon zkEVM:

| pair            | token0 | token1 |
| --------------- | ------ | ------ |
| DYSON-USDC pair | $DYSN  | $USDC  |
| WETH-USDC pair  | $WETH  | $USDC  |

Linea:

| pair           | token0 | token1 |
| -------------- | ------ | ------ |
| WETH-USDC pair | $USDC  | $WETH  |

### 2. Swap through Router Contract&#x20;

Alternatively, you can execute a swap through the Router contract. You can initiate a swap using the functions below within the Router contract.

<pre class="language-solidity"><code class="lang-solidity"><strong>// Router.sol
</strong><strong>function swap(
</strong>    address tokenIn, 
    address tokenOut, 
    uint index, 
    address to, 
    uint input, 
    uint minOutput) external returns (uint output)
</code></pre>

Parameters:

* `tokenIn`: Address of the spent token.
* `tokenOut`: Address of the received token.
* `index`: Number of the pair instance.
* `to` : Address that will receive tokenOut.
* `input` : Amount of tokenIn to swap.
* `minOutput` : Minimum amount of tokenOut expected.

Return Value:

* `output` : Amount of token swapped.

In the case of swapping ETH, you can use the functions below.

```solidity
// Router.sol
function swapETHIn(
    address tokenOut, 
    uint index, 
    address to, 
    uint minOutput) external payable returns (uint output)
```

Parameters:

* `tokenOut` : Address of received token.
* `index` : Number of pair instance.
* `to` : Address that will receive tokenOut.
* `minOutput` : Minimum of token1 expected to receive.

Return Value:

* `output` : Amount of tokenOut received.

```solidity
// Router.sol
function swapETHOut(
    address tokenIn, 
    uint index, 
    address to, 
    uint input, 
    uint minOutput) external returns (uint output)
```

Parameters:

* `tokenIn` : Address of spent token.
* `index` : Number of pair instance.
* `to` : Address that will receive ETH.
* `input` : Amount of tokenIn to swap.
* `minOutput` : Minimum of ETH expected to receive.

Return Value:

* `output` : Amount of ETH received.

#### Set Up your Contract

1. Declare the solidity version used to compile the contract.
2. Import IRouter interface and IERC20 interface.
3. Create your custom contract. The following code snippets showcase the process of swapping between $DYSN and $USDC, as well as between $WETH and $USDC.

<pre class="language-solidity"><code class="lang-solidity">// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

interface IRouter {
    function swap(address tokenIn, address tokenOut, uint index, address to, uint input, uint minOutput) external returns (uint output);
<strong>    function swapETHIn(address tokenOut, uint index, address to, uint minOutput) external payable returns (uint output);
</strong><strong>    function swapETHOut(address tokenIn, uint index, address to, uint input, uint minOutput) external returns (uint output);    
</strong><strong>}
</strong>
interface IERC20 {
    function approve(address spender, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract MySwapTest {
    // The Router contract on Polygon zkEVM.
    address public constant router = 0xADa6e69781399990d42bEcB1a9427955FFA73Bdc;
    // The $DYSN contract on Polygon zkEVM.
    address public constant DYSN = 0x9CBD81b43ba263ca894178366Cfb89A246D1159C;
    // The $USDC contract on Polygon zkEVM.
    address public constant USDC = 0xA8CE8aee21bC2A48a5EF670afCc9274C7bbbC035;
    
    function swapDYSNToUSDC(uint index, address to, uint amountIn, uint minOutput) external returns (uint output) {
        IERC20(DYSN).transferFrom(msg.sender, address(this), amountIn)
        IERC20(DYSN).approve(router, amountIn);
        IRouter(router).swap(DYSN, USDC, index, to, amountIn, minOutput);
    }
    
    function swapUSDCToDYSN(uint index, address to, uint amountIn, uint minOutput) external returns (uint output) {
        IERC20(USDC).transferFrom(msg.sender, address(this), amountIn)
        IERC20(USDC).approve(router, amountIn);
        IRouter(router).swap(USDC, DYSN, index, to, amountIn, minOutput);
    }
    
    // Ensure this contract has enough ETH before performing `swapETHToUSDC`.
    function swapETHToUSDC(uint swapETHAmount, uint index, address to, uint minOutput) external payable returns (uint output) {
        IRouter(router).swapETHIn{value: swapETHAmount}(USDC, index, to, minOutput);
    }
    
    // Ensure this contract has enough USDC before performing `swapUSDCToETH`.
    function swapUSDCToETH(uint index, address to, uint input, uint minOutput) external returns (uint output) {
        IRouter(router).swapETHOut(USDC, index, to, input, minOutput);
    }
}

</code></pre>

#### swapWithMultiHops

In the context of Dyson Finance, assuming there are currently three pairs: `token0-token1`, `token1-token2`, and `token2-token3`. If a user intends to swap from token0 to token3, they should employ the following functions: `swapWithMultiHops`, `swapETHInWithMultiHops`, or `swapETHOutWithMultiHops` to achieve the desired outcome, as opposed to invoking a regular swap function.

```solidity
// Router.sol
function swapWithMultiHops(
    address[] calldata tokens, 
    uint[] calldata indexes, 
    address to, 
    uint input, 
    uint minOutput) external returns (uint output)
```

Parameters:

* `tokens` : Array of swapping tokens.
* `indexes` : Array of pair instance.
* `to` : Address that will receive tokenOut.
* `input` : Amount of tokenIn to swap.
* `minOutput` : Minimum amount of tokenOut expected.

Return Value:

* `output` : Amount of tokenOut received.

Reiterating, our platform indeed facilitates the swapping of ETH in and out with multiple hops. The fundamental logic aligns with the original `swapWithMultiHops` function, with these specific functions aiding in the seamless conversion between ETH and WETH as required. In particular, `swapETHInWithMultiHops` transforms the user's input ETH to WETH before the actual swap, while `swapETHOutWithMultiHops` converts the output WETH back to ETH after swap and returns it to the user.

```solidity
// Router.sol
function swapETHInWithMultiHops(
    address[] calldata tokens, 
    uint[] calldata indexes, 
    address to, 
    uint minOutput) external payable returns (uint output)
    
function swapETHOutWithMultiHops(
    address[] calldata tokens, 
    uint[] calldata indexes, 
    address to, 
    uint input, 
    uint minOutput) external returns (uint output)
```

#### Set Up your Contract

* Declare the solidity version used to compile the contract.
* Import IRouter interface.
* Write your own contract. Let's consider a scenario where there are three pairs: `token0-token1`, `token1-token2`, and `token2-token3`, with each pair having an index of 1. Now, if a user aims to execute a swap from token0 to token3 using the `swapWithMultiHops` function, they need to provide an array that signifies the token paths: `[token0, token1, token2, token3]`, along with the indices of each pair: `[1, 1, 1].`

```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

interface IRouter {
    function swapWithMultiHops(address[] calldata tokens, uint[] calldata indexes, address to, uint input, uint minOutput) external returns (uint output);
    function swapETHInWithMultiHops(address[] calldata tokens, uint[] calldata indexes, address to, uint minOutput) external payable returns (uint output);
    function swapETHOutWithMultiHops(address[] calldata tokens, uint[] calldata indexes, address to, uint input, uint minOutput) external returns (uint output);
}

contract MySwapTest {

    // The Router contract on Polygon zkEVM.
    address public constant router = 0xADa6e69781399990d42bEcB1a9427955FFA73Bdc;

    address public constant token0 = 0x9cBd81B43Ba263Ca894178366CFB89A246d11534;
    address public constant token1 = 0xA8ce8aeE21bc2a48a5eF670AFcc9274C7BBbC037;
    address public constant token2 = 0xA8ce8aeE21bc2a48a5eF670AFcc9274C7BBbC037;
    address public constant token3 = 0xA8ce8aeE21bc2a48a5eF670AFcc9274C7BBbC037;

    uint public token0In = 100e18; // 100 token0
    uint public minToken3Out = 90e18; // 10% slippage
    
    /** 
        Pair = (token0, token1)
        Pair2 = (token1, token2)
        Pair3 = (token2, token3)
        Path = Pair(token0 -> token1) -> Pair2(token1 -> token2) -> Pair3(token2 -> token3)
    **/
    function swapToken0ToToken3() external returns (uint outputToken3) {
        address[] memory tokens = new address[](4);
        tokens[0] = token0;
        tokens[1] = token1;
        tokens[2] = token2;
        tokens[3] = token3;

        // We assumed all pair's index = 1. The index here represents the pair instance.
        uint[] memory indexes = new uint[](3);
        indexes[0] = 1;
        indexes[1] = 1;
        indexes[2] = 1;
        
        // tokens = [token0, token1, token2, token3], indexes = [1, 1, 1],
        // Which means user input token0, and get token3 back
        outputToken3 = IRouter(router).swapWithMultiHops(tokens, indexes, address(this), token0In, minToken3Out);
        
    }
}
```
