# AddressBook

AddressBook serves as a central registry for various addresses within the Dyson Finance ecosystem, managing important addresses and settings for the protocol.

### file

Allows the owner to update specific addresses in the contract.

```solidity
function file(
    bytes32 name, 
    address value) external
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>name</td><td>bytes32</td><td>The name of the address to update.</td></tr><tr><td>value</td><td>address</td><td>The new address.</td></tr></tbody></table>



### getCanonicalIdOfPair

Retrieves the canonical ID of a pair of tokens.

```solidity
function getCanonicalIdOfPair(
    address token0, 
    address token1) external view returns (uint256)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>token0</td><td>address</td><td>Address of the first token in the pair.</td></tr><tr><td>token1</td><td>address</td><td>Address of the second token in the pair.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>canonicalId</td><td>uint</td><td>The canonical ID of the pair.</td></tr></tbody></table>

### setCanonicalIdOfPair

Allows the owner to set the canonical ID for a pair of tokens.

```solidity
function setCanonicalIdOfPair(
    address token0, 
    address token1, 
    uint256 canonicalId) external
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>token0</td><td>address</td><td>Address of the first token in the pair.</td></tr><tr><td>token1</td><td>address</td><td>Address of the second token in the pair.</td></tr><tr><td>canonicalId</td><td>uint</td><td>The new canonical ID for the pair.</td></tr></tbody></table>

### setBribeOfGauge

Allows the owner to set the bribe address for a gauge.

```solidity
function setBribeOfGauge(
    address gauge, 
    address bribe) external
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>gauge</td><td>address</td><td>Address of the gauge.</td></tr><tr><td>bribe</td><td>address</td><td>Address of the bribe.</td></tr></tbody></table>
