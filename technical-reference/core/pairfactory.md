# PairFactory

PairFactory is the contract that deploys DysonPair. Unlike Uniswap, Dyson allows multiple Pair instances for a trading pair of two tokens. Factory also serves as a beacon providing the current controller address for all pairs.

### **allPairsLength**

Retrieves the total number of created pairs.

```solidity
function allPairsLength() external view returns (uint)
```

Return Values:

<table><thead><tr><th width="191">Name</th><th width="85">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>None</td><td>uint</td><td>Total number of created pairs.</td></tr></tbody></table>



### **getInitCodeHash**

Retrieves the keccak256 hash of the creation code for the `Pair` contract.

```solidity
function getInitCodeHash() external pure returns (bytes32)
```

Return Values:

<table><thead><tr><th width="191">Name</th><th width="100">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>None</td><td>bytes32</td><td>Keccak256 hash of the <code>Pair</code> contract creation code.</td></tr><tr><td></td><td></td><td></td></tr></tbody></table>

### **createPair**

Creates a new Pair contract with the specified token addresses and initializes it. This function introduces a mechanism to generate unique `Pair` contract instances in Solidity. This uniqueness is achieved through the utilization of a cryptographic hash known as `salt`. The `salt` is computed by encoding (hashing) a combination of `token0`, `token1`, and `id`. By incorporating `salt`, the function ensures that each created `Pair` contract possesses a distinctive identifier, guarding against the duplication of identical configurations.

```solidity
function createPair(
    address tokenA, 
    address tokenB) external returns (address pair)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="102">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>tokenA</td><td>address</td><td>Address of the first token.</td></tr><tr><td>tokenB</td><td>address</td><td>Address of the second token.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="97">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>pair</td><td>address</td><td>Address of the newly created Pair contract.</td></tr><tr><td></td><td></td><td></td></tr></tbody></table>

### **setController**

Sets a new controller address. Can only be called by the current controller.

```solidity
function setController(
    address _controller) external
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="94">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>_controller</td><td>address</td><td>The new controller address.</td></tr><tr><td></td><td></td><td></td></tr></tbody></table>

### **becomeController**

Allows the pending controller to become the new controller. Must be called by the pending controller.

```solidity
function becomeController() external
```

### **open2public**

Opens the factory to public creation of pairs. Must be called by the current controller.

```solidity
function open2public() external
```
