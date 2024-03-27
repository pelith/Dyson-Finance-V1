---
description: >-
  The TransferHelper library provides functions for safely interacting with
  ERC-20 tokens and Ether transfers.
---

# TransferHelper

### safeApprove

Safely approves spending of a specified amount of tokens by a target address.

```solidity
function safeApprove(
    address token, 
    address to, 
    uint value) internal
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>token</td><td>address</td><td>Address of the ERC-20 token.</td></tr><tr><td>to</td><td>address</td><td>Address that will be approved to spend the tokens.</td></tr><tr><td>value</td><td>uint</td><td>Amount of tokens to approve.</td></tr></tbody></table>

### safeTransfer

Safely transfers a specified amount of tokens to a target address.

```solidity
function safeTransfer(
    address token, 
    address to, 
    uint value) internal
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="461">Description</th></tr></thead><tbody><tr><td>token</td><td>address</td><td>Address of the ERC-20 token.</td></tr><tr><td>to</td><td>address</td><td>Address to which the tokens will be transferred.</td></tr><tr><td>value</td><td>uint</td><td>Amount of tokens to transfer.</td></tr></tbody></table>

### safeTransferFrom

Safely transfers a specified amount of tokens from one address to another.

```solidity
function safeTransferFrom(
    address token, 
    address from, 
    address to, 
    uint value) internal
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>token</td><td>address</td><td>Address of the ERC-20 token.</td></tr><tr><td>from</td><td>address</td><td>Address from which the tokens will be transferred.</td></tr><tr><td>to</td><td>address</td><td>Address to which the tokens will be transferred.</td></tr><tr><td>value</td><td>uint</td><td>Amount of tokens to transfer.</td></tr></tbody></table>

### safeTransferETH

Safely transfers a specified amount of Ether to a target address.

```solidity
function safeTransferETH(
    address to, 
    uint value) internal
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>to</td><td>address</td><td>Address to which the Ether will be transferred.</td></tr><tr><td>value</td><td>uint</td><td>Amount of Ether to transfer.</td></tr></tbody></table>
