# Router

Router serves as an entry point for swapping, depositing, and withdrawing. It helps users handle WETH wrap/unwrap issues and prevents token approval for multiple pairs. Users can deposit dual investments, swap, boost, and stake DYSON.

### rely

Allows another address to transfer tokens from this contract.

```solidity
function rely(
    address tokenAddress, 
    address contractAddress, 
    bool enable) onlyOwner external
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>tokenAddress</td><td>address</td><td>Address of the token to approve.</td></tr><tr><td>contractAddress</td><td>address</td><td>Address to grant allowance.</td></tr><tr><td>enable</td><td>bool</td><td>True to enable allowance, false otherwise.</td></tr></tbody></table>

### rescueERC20

Rescues tokens stuck in this contract.

```solidity
function rescueERC20(
    address tokenAddress, 
    address to, 
    uint256 amount) onlyOwner external
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>tokenAddress</td><td>address</td><td>Address of the token to be rescued.</td></tr><tr><td>to</td><td>address</td><td>Address that will receive the rescued tokens.</td></tr><tr><td>amount</td><td>uint</td><td>Amount of tokens to be rescued.</td></tr></tbody></table>

### receive

Receives ETH only from the WETH contract.

```solidity
receive() external payable
```

### \_swap

Internal function responsible for executing token swaps. Essentially, this function triggers the swap function within the Pair contract.

```solidity
function _swap(
    address tokenIn, 
    address tokenOut, 
    uint index, 
    address to, 
    uint input, 
    uint minOutput) internal returns (uint output)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>tokenIn</td><td>address</td><td>Address of the token to swap.</td></tr><tr><td>tokenOut</td><td>address</td><td>Address of the received token.</td></tr><tr><td>index</td><td>uint</td><td>Number of the pair instance.</td></tr><tr><td>to</td><td>address</td><td>Address that will receive the output token.</td></tr><tr><td>input</td><td>uint</td><td>Amount of tokenIn to swap.</td></tr><tr><td>minOutput</td><td>uint</td><td>Minimum amount of tokenOut expected.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>output</td><td>uint</td><td>Amount of tokenOut received.</td></tr></tbody></table>

### unwrapAndSendETH

Internal function to unwrap WETH and send ETH. This function is utilized in executing `withdrawETH` , `swapETHOut` and `swapETHOutWithMultiHops` operations.

```solidity
function unwrapAndSendETH(
    address to, 
    uint amount) internal
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>to</td><td>address</td><td>Address that will receive the ETH.</td></tr><tr><td>amount</td><td>uint</td><td>Amount of ETH to unwrap and send.</td></tr></tbody></table>

### swap

External function for swapping tokenIn for tokenOut. This functions simply invokes `_swap` .

```solidity
function swap(
    address tokenIn, 
    address tokenOut, 
    uint index, 
    address to, 
    uint input, 
    uint minOutput) external returns (uint output)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>tokenIn</td><td>address</td><td>Address of the spent token.</td></tr><tr><td>tokenOut</td><td>address</td><td>Address of the received token.</td></tr><tr><td>index</td><td>uint</td><td>Number of the pair instance.</td></tr><tr><td>to</td><td>address</td><td>Address that will receive tokenOut.</td></tr><tr><td>input</td><td>uint</td><td>Amount of tokenIn to swap.</td></tr><tr><td>minOutput</td><td>uint</td><td>Minimum amount of tokenOut expected.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>output</td><td>uint</td><td>Amount of tokenOut received.</td></tr></tbody></table>

### swapETHIn

Swaps ETH for tokenOut. This function converts input ETH to WETH before executing an actual swap.

```solidity
function swapETHIn(
    address tokenOut, 
    uint index, 
    address to, 
    uint minOutput) external payable returns (uint output)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>tokenOut</td><td>address</td><td>Address of the received token.</td></tr><tr><td>index</td><td>uint</td><td>Number of the pair instance.</td></tr><tr><td>to</td><td>address</td><td>Address that will receive tokenOut.</td></tr><tr><td>minOutput</td><td>uint</td><td>Minimum amount of tokenOut expected.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>output</td><td>uint</td><td>Amount of tokenOut received.</td></tr></tbody></table>

### swapETHOut

Swaps tokenIn for ETH. This function converts output  WETH to ETH after executing an actual swap, and send ETH back to the swapper.

```solidity
function swapETHOut(
    address tokenIn, 
    uint index, 
    address to, 
    uint input, 
    uint minOutput) external returns (uint output)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>tokenIn</td><td>address</td><td>Address of the spent token.</td></tr><tr><td>index</td><td>uint</td><td>Number of the pair instance.</td></tr><tr><td>to</td><td>address</td><td>Address that will receive ETH.</td></tr><tr><td>input</td><td>uint</td><td>Amount of tokenIn to swap.</td></tr><tr><td>minOutput</td><td>uint</td><td>Minimum amount of ETH expected.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>output</td><td>uint</td><td>Amount of ETH received.</td></tr></tbody></table>

### swapWithMultiHops

Swaps tokenIn for tokenOut with multiple hops. Please refer to [swap with multiple hops](../../guides/integration-of-swap/perform-a-swap.md#swapwithmultihops) section for an in-depth understanding of how this operation functions.

```solidity
function swapWithMultiHops(
    address[] calldata tokens, 
    uint[] calldata indexes, 
    address to, 
    uint input, 
    uint minOutput) external returns (uint output)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="116">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>tokens</td><td>address[]</td><td>Array of swapping tokens.</td></tr><tr><td>indexes</td><td>uint[]</td><td>Array of pair instance.</td></tr><tr><td>to</td><td>address</td><td>Address that will receive tokenOut.</td></tr><tr><td>input</td><td>uint</td><td>Amount of tokenIn to swap.</td></tr><tr><td>minOutput</td><td>uint</td><td>Minimum amount of tokenOut expected.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>output</td><td>uint</td><td>Amount of tokenOut received.</td></tr></tbody></table>

### swapETHInWithMultiHops

Swaps ETH for tokenOut with multiple hops. Please refer to [swap with multiple hops](../../guides/integration-of-swap/perform-a-swap.md#swapwithmultihops) section for an in-depth understanding of how this operation functions.

```solidity
function swapETHInWithMultiHops(
    address[] calldata tokens, 
    uint[] calldata indexes, 
    address to, 
    uint minOutput) external payable returns (uint output)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="106">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>tokens</td><td>address[]</td><td>Array of swapping tokens.</td></tr><tr><td>indexes</td><td>uint[]</td><td>Array of pair instance.</td></tr><tr><td>to</td><td>address</td><td>Address that will receive tokenOut.</td></tr><tr><td>minOutput</td><td>uint</td><td>Minimum amount of tokenOut expected.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>output</td><td>uint</td><td>Amount of tokenOut received.</td></tr></tbody></table>

### swapETHOutWithMultiHops

Swaps tokenIn for ETH with multiple hops. Please refer to [swap with multiple hops](../../guides/integration-of-swap/perform-a-swap.md#swapwithmultihops) section for an in-depth understanding of how this operation functions.

```solidity
function swapETHOutWithMultiHops(
    address[] calldata tokens, 
    uint[] calldata indexes, 
    address to, 
    uint input, 
    uint minOutput) external returns (uint output)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="116">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>tokens</td><td>address[]</td><td>Array of swapping tokens.</td></tr><tr><td>indexes</td><td>uint[]</td><td>Array of pair instance.</td></tr><tr><td>to</td><td>address</td><td>Address that will receive ETH.</td></tr><tr><td>input</td><td>uint</td><td>Amount of tokenIn to swap.</td></tr><tr><td>minOutput</td><td>uint</td><td>Minimum amount of ETH expected.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>output</td><td>uint</td><td>Amount of ETH received.</td></tr></tbody></table>

### \_deposit

Internal function to perform a dual investment deposit. Essentially, this function simply triggers the `deposit` functions in Pair contract.

```solidity
function _deposit(
    address tokenIn, 
    address tokenOut, 
    uint index, 
    address to, 
    uint input, 
    uint minOutput, 
    uint time) internal returns (uint output)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>tokenIn</td><td>address</td><td>Address of the spent token.</td></tr><tr><td>tokenOut</td><td>address</td><td>Address of the received token.</td></tr><tr><td>index</td><td>uint</td><td>Number of the pair instance.</td></tr><tr><td>to</td><td>address</td><td>Address that will receive Pair note.</td></tr><tr><td>input</td><td>uint</td><td>Amount of tokenIn to deposit.</td></tr><tr><td>minOutput</td><td>uint</td><td>Minimum amount of tokenOut expected if the swap is performed.</td></tr><tr><td>time</td><td>uint</td><td>Lock time for the deposit.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>output</td><td>uint</td><td>Amount of tokenOut received if the swap is performed.</td></tr></tbody></table>

### deposit

External function for depositing tokenIn to receive Pair notes. This function simply triggers the `_deposit` function.

```solidity
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

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>tokenIn</td><td>address</td><td>Address of the spent token.</td></tr><tr><td>tokenOut</td><td>address</td><td>Address of the received token.</td></tr><tr><td>index</td><td>uint</td><td>Number of the pair instance.</td></tr><tr><td>to</td><td>address</td><td>Address that will receive Pair note.</td></tr><tr><td>input</td><td>uint</td><td>Amount of tokenIn to deposit.</td></tr><tr><td>minOutput</td><td>uint</td><td>Minimum amount of tokenOut expected if the swap is performed.</td></tr><tr><td>time</td><td>uint</td><td>Lock time for the deposit.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>output</td><td>uint</td><td>Amount of tokenOut received if the swap is performed.</td></tr></tbody></table>

### depositETH

Deposits ETH to receive Pair notes. This function converts input ETH to WETH before executing an actual deposit to Pair contract.

```solidity
function depositETH(
    address tokenOut, 
    uint index, 
    address to, 
    uint minOutput, 
    uint time) external payable returns (uint output)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>tokenOut</td><td>address</td><td>Address of the received token.</td></tr><tr><td>index</td><td>uint</td><td>Number of the pair instance.</td></tr><tr><td>to</td><td>address</td><td>Address that will receive Pair note.</td></tr><tr><td>minOutput</td><td>uint</td><td>Minimum amount of tokenOut expected if the swap is performed.</td></tr><tr><td>time</td><td>uint</td><td>Lock time for the deposit.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>output</td><td>uint</td><td>Amount of tokenOut received if the swap is performed.</td></tr></tbody></table>

### withdraw

Withdraws a Pair note. This function simply triggers the `withdrawFrom` function in Pair contract.

Please refer to [withdraw through Router](../../guides/integration-of-dual-investment/perform-a-dual-investment-withdrawal.md#withdraw) section for an in-depth understanding of how this operation functions.

```solidity
function withdraw(
    address pair, 
    uint index, 
    address to) external returns (uint token0Amt, uint token1Amt)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>pair</td><td>address</td><td>Pair contract address.</td></tr><tr><td>index</td><td>uint</td><td>Index of the note to withdraw.</td></tr><tr><td>to</td><td>address</td><td>Address that will receive either token0 or token1.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>token0Amt</td><td>uint</td><td>Amount of token0 withdrawn.</td></tr><tr><td>token1Amt</td><td>uint</td><td>Amount of token1 withdrawn.</td></tr></tbody></table>

### withdrawMultiPositions

Withdraws multiple Pair notes. This function withdraws multiple positions of a user across the pools.

Please refer to [withdraw through Router](../../guides/integration-of-dual-investment/perform-a-dual-investment-withdrawal.md#withdraw)[ ](../../guides/integration-of-dual-investment/perform-a-dual-investment-withdrawal.md#withdrawmultipositions)section for an in-depth understanding of how this operation functions.

```solidity
function withdrawMultiPositions(
    address[] calldata pairs, 
    uint[] calldata indexes, 
    address[] calldata tos) external returns (uint[] memory token0Amounts, uint[] memory token1Amounts)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="110">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>pairs</td><td>address[]</td><td>Array of Pair contract addresses.</td></tr><tr><td>indexes</td><td>uint[]</td><td>Array of indexes of the notes to withdraw.</td></tr><tr><td>tos</td><td>address[]</td><td>Array of addresses that will receive either token0 or token1.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>token0Amounts</td><td>uint[]</td><td>Array of amounts of token0 withdrawn.</td></tr><tr><td>token1Amounts</td><td>uint[]</td><td>Array of amounts of token1 withdrawn.</td></tr></tbody></table>

### withdrawETH

Withdraws a Pair note and, if either token0 or token1 withdrawn is WETH, withdraws from WETH and sends ETH to the receiver.

```solidity
function withdrawETH(
    address pair, 
    uint index, 
    address to) external returns (uint token0Amt, uint token1Amt)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>pair</td><td>address</td><td>Pair contract address.</td></tr><tr><td>index</td><td>uint</td><td>Index of the note to withdraw.</td></tr><tr><td>to</td><td>address</td><td>Address that will receive either token0 or token1.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>token0Amt</td><td>uint</td><td>Amount of token0 withdrawn.</td></tr><tr><td>token1Amt</td><td>uint</td><td>Amount of token1 withdrawn.</td></tr></tbody></table>

### depositToGauge

Deposits sDYSON to a gauge. This function simply triggers `deposit` function in Gauge contract.

```solidity
function depositToGauge(
    address gauge, 
    uint amount, 
    address to) external
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>gauge</td><td>address</td><td>Gauge contract address.</td></tr><tr><td>amount</td><td>uint</td><td>Amount of sDYSON to deposit.</td></tr><tr><td>to</td><td>address</td><td>Address that owns the position of this deposit.</td></tr></tbody></table>

### stakeDyson

Stakes DYSON to sDYSON. This function simply triggers `stake` function in sDYSON contract.

```solidity
function stakeDyson(
    address to, 
    uint amount, 
    uint lockDuration) external returns (uint sDYSONAmount)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>to</td><td>address</td><td>Address that owns the position of this stake.</td></tr><tr><td>amount</td><td>uint</td><td>Amount of DYSON to stake.</td></tr><tr><td>lockDuration</td><td>uint</td><td>Lock duration.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>sDYSONAmount</td><td>uint</td><td>Amount of sDYSON received.</td></tr></tbody></table>

### selfPermit

Enables this contract to expend a specified token from the `msg.sender` to facilitate [ERC-2612 ](https://eips.ethereum.org/EIPS/eip-2612)functionality.

```solidity
function selfPermit(
    address token,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s) public 
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>token</td><td>address</td><td>Address of the token spent.</td></tr><tr><td>value</td><td>uint</td><td>The amount that can be spent of token.</td></tr><tr><td>deadline</td><td>uint</td><td>A timestamp, the current block time must be less than or equal to this timestamp.</td></tr><tr><td>v</td><td>uint8</td><td>Must produce a valid secp256k1 signature from the holder along with r and s.</td></tr><tr><td>r</td><td>bytes32</td><td>Must produce a valid secp256k1 signature from the holder along with v and s.</td></tr><tr><td>s</td><td>bytes32</td><td>Must produce a valid secp256k1 signature from the holder along with v and r.</td></tr></tbody></table>

### setApprovalForAllWithSig

Sets approval for all positions of a pair using a signature. Please refer to [Approve Router for withdrawal with signature](../../guides/integration-of-dual-investment/perform-a-dual-investment-withdrawal.md#approve-router-for-withdrawal-with-signature) section for an in-depth understanding of how this operation functions.

```solidity
function setApprovalForAllWithSig(
    address pair, 
    bool approved, 
    uint deadline, 
    bytes calldata sig) public
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>pair</td><td>address</td><td>Pair contract address.</td></tr><tr><td>approved</td><td>bool</td><td>True to approve, false to revoke.</td></tr><tr><td>deadline</td><td>uint</td><td>Deadline when the signature expires.</td></tr><tr><td>sig</td><td>bytes</td><td>Signature.</td></tr></tbody></table>

### multicall

Multi delegatecall without supporting payable. This function is primarily utilized when a user needs to set approval for withdrawal across multiple pools.

```solidity
function multicall(
    bytes[] calldata data) public returns (bytes[] memory results)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>data</td><td>bytes[]</td><td>Array of bytes of function calldata to be delegate called.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>results</td><td>bytes[]</td><td>Array of bytes containing the results of each delegate call.</td></tr></tbody></table>

### fairPrice

Calculates the price of token1 in token0 based on the following formula:

```solidity
fairPrice = reserve1 * sqrt(1-fee0) / (reserve0 * sqrt(1-fee1) )
```

Explore the [_fair price_](https://docs.dyson.finance/mechanisms/dual-investment#fair-price) section in our white paper for comprehensive insights into the price calculation mechanism.&#x20;

```solidity
function fairPrice(
    address pair, 
    uint token0Amt) external view returns (uint token1Amt)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>pair</td><td>address</td><td>Pair contract address.</td></tr><tr><td>token0Amt</td><td>uint</td><td>Amount of token0.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>token1Amt</td><td>uint</td><td>Amount of token1.</td></tr></tbody></table>
