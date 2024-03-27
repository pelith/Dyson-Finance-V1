# DYSON

DYSON is an ERC20 contract for the $DYSON token.

### rescueERC20

Rescues ERC-20 tokens stuck in the contract and transfers them to a specified address.

```solidity
function rescueERC20(
    address tokenAddress, 
    address to, 
    uint256 amount) onlyOwner external
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>tokenAddress</td><td>address</td><td>Address of the ERC-20 token to be rescued.</td></tr><tr><td>to</td><td>address</td><td>Address that will receive the rescued tokens.</td></tr><tr><td>amount</td><td>uint</td><td>Amount of tokens to be rescued.</td></tr></tbody></table>

### addMinter

Enables an address to mint new tokens. Currently, only the Farm contract is authorized as a minter who is responsible for minting $DYSN rewards.

```solidity
function addMinter(
    address _minter) external onlyOwner
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>_minter</td><td>address</td><td>Address to be added as a minter.</td></tr></tbody></table>

### removeMinter

Removes an address from the list of minters, preventing it from minting new tokens.

```solidity
function removeMinter(
    address _minter) external onlyOwner
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>_minter</td><td>address</td><td>Address to be removed from minters.</td></tr></tbody></table>

### approve

Approves the spender to spend a specified amount of tokens on behalf of the owner.

```solidity
function approve(
    address spender, 
    uint amount) external returns (bool)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>spender</td><td>address</td><td>Address allowed to spend the tokens.</td></tr><tr><td>amount</td><td>uint</td><td>Amount of tokens to approve.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>None</td><td>bool</td><td>Boolean indicating success.</td></tr></tbody></table>

### transfer

Transfers a specified amount of tokens to a target address.

```solidity
function transfer(    
    address to, 
    uint amount) external returns (bool)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>to</td><td>address</td><td>Address to which tokens will be transferred.</td></tr><tr><td>amount</td><td>uint</td><td>Amount of tokens to transfer.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>None</td><td>bool</td><td>Boolean indicating success.</td></tr></tbody></table>

### transferFrom

Transfers a specified amount of tokens from one address to another, subject to approval.

```solidity
function transferFrom(
    address from, 
    address to, 
    uint amount) external returns (bool)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>from</td><td>address</td><td>Address from which tokens will be transferred.</td></tr><tr><td>to</td><td>address</td><td>Address to which tokens will be transferred.</td></tr><tr><td>amount</td><td>uint</td><td>Amount of tokens to transfer.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>None</td><td>bool</td><td>Boolean indicating success.</td></tr></tbody></table>

### mint

Mints a specified amount of new tokens and assigns them to a specified address.

```solidity
function mint(
    address to, 
    uint amount) external returns (bool)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>to</td><td>address</td><td>Address to receive the minted tokens.</td></tr><tr><td>amount</td><td>uint</td><td>Amount of tokens to mint.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>None</td><td>bool</td><td>Boolean indicating success.</td></tr></tbody></table>

### burn

Burns a specified amount of tokens from a specified address.

```solidity
function burn(
    address from, 
    uint amount) external returns (bool)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>from</td><td>address</td><td>Address from which tokens will be burned.</td></tr><tr><td>amount</td><td>uint</td><td>Amount of tokens to burn.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>None</td><td>bool</td><td>Boolean indicating success.</td></tr><tr><td></td><td></td><td></td></tr></tbody></table>

### permit

Implements the [EIP-2612](https://eips.ethereum.org/EIPS/eip-2612) permit function, allowing an owner to approve token spending with a signature.

```solidity
function permit(
    address _owner,
    address _spender,
    uint256 _amount,
    uint256 _deadline,
    uint8 _v,
    bytes32 _r,
    bytes32 _s) external
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>_owner</td><td>address</td><td>Token owner's address.</td></tr><tr><td>_spender</td><td>address</td><td>Address allowed to spend the tokens.</td></tr><tr><td>_amount</td><td>uint</td><td>Amount of tokens to approve.</td></tr><tr><td>_deadline</td><td>uint</td><td>Deadline for the permit.</td></tr><tr><td>_v</td><td>uint8</td><td>Must produce a valid secp256k1 signature from the holder along with _r <em>and</em> _s.</td></tr><tr><td>_r</td><td>bytes32</td><td>Must produce a valid secp256k1 signature from the holder along with _v <em>and</em>  _s.</td></tr><tr><td>_s</td><td>bytes32</td><td>Must produce a valid secp256k1 signature from the holder along with _v and _r.</td></tr></tbody></table>
