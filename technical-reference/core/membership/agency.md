# Agency

This contract oversees the referral mechanism in Dyson Finance. When a user deposits in Pair and is registered in the referral system, they receive additional DYSON tokens as a reward. Each user in the referral system is designated as an Agent, and the referral of an Agent is referred to as the child of that Agent.

### **rescueERC20**

```solidity
function rescueERC20(
    address tokenAddress, 
    address to, 
    uint256 amount) onlyOwner external
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>tokenAddress</td><td>address</td><td>Address of the ERC20 token.</td></tr><tr><td>to</td><td>address</td><td>Address that will receive the rescued tokens.</td></tr><tr><td>amount</td><td>uint</td><td>Amount of tokens to be rescued.</td></tr></tbody></table>



### **addController**

Adds a new address as a controller. Only callable by the owner. A controller possesses the authority to invoke the `adminAdd` function within the Agency contract.

```solidity
function addController(
    address _controller) external onlyOwner
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>_controller</td><td>address</td><td>Address to be added as a controller.</td></tr></tbody></table>

### **removeController**

Removes an address from the list of controllers. Only callable by the owner.

```solidity
function removeController(
    address _controller) external onlyOwner
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>_controller</td><td>address</td><td>Address to be removed from controllers.</td></tr><tr><td></td><td></td><td></td></tr><tr><td></td><td></td><td></td></tr></tbody></table>

### **adminAdd**

Adds a new child agent to the root agent. This child becomes a 1st generation agent who owns a tier1 NFT. Only callable by the owner or controllers.

```solidity
function adminAdd(
    address newUser) external returns (uint id)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>newUser</td><td>address</td><td>Address of the new agent.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>id</td><td>uint</td><td>Id of the new agent.</td></tr></tbody></table>

### **transfer**

Transfers agent data to a different user, only callable by the AgentNFT contract. It's important to note that the agent cannot be transferred again until the cooldown time, calculated as `(generation + 1) * TRANSFER_CD`, is completed. This cooldown time is ten times longer than the cooldown time for swapping SP to DYSON.

```solidity
function transfer(
    address from, 
    address to, 
    uint id) external returns (bool)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>from</td><td>address</td><td>Previous owner of the agent.</td></tr><tr><td>to</td><td>address</td><td>User who will receive the agent.</td></tr><tr><td>id</td><td>uint</td><td>Index of the agent to be transferred.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>None</td><td>bool</td><td>True if the transfer is successful.</td></tr></tbody></table>

### **register**

This function is a critical component that allows users to join the referral system by providing an invite code (`onceSig`) and the signature of their referrer (`parentSig`). This function facilitates the growth of the referral network by establishing relationships between referrers and referees within the system. Let's break down the key aspects of the `register` function:

1. **Validation**: The function checks whether the current timestamp is before the specified deadline to ensure the invite code is still valid.
2. **Agent Check**: Verifies that the user calling the function does not already have an existing agent in the referral system.
3. **One-Time Code Verification**: Validates the `onceSig` (invite code) by recovering the address associated with the provided signature. Ensures the invite code has not been used before.
4. **Referrer Signature Verification**: Validates the `parentSig` (referrer's signature) to confirm the legitimacy of the referrer. Notice that <mark style="color:orange;">**when the parent is a contract wallet, the**</mark><mark style="color:orange;">** **</mark><mark style="color:orange;">**`parentSig`**</mark><mark style="color:orange;">** **</mark><mark style="color:orange;">**provided will be the address of the parent instead of a signature.**</mark>
5. **Referrer Information Retrieval**: Retrieves the referrer's agent information, including their ID, from the system.
6. **Registration Delay Check**: Ensures that the referrer has passed the registration delay before being able to refer new users.
7. **New Agent Creation**: Creates a new agent for the registering user, establishing a parent-child relationship with the referrer.
8. **One-Time Code Deactivation**: Marks the invite code as used to prevent its reuse.
9. **Reward Transfer (Optional)**: If the user sent some Ether along with the registration, it is transferred to the referrer as a reward.

**Note**

* The function makes use of cryptographic techniques, including signature verification (`ecrecover`), to ensure the security and integrity of the registration process.
* The function also involves an optional Ether transfer as a reward to the referrer for bringing in a new user.

```solidity
function register(
    bytes memory parentSig, 
    bytes memory onceSig, 
    uint deadline) payable external returns (uint id)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>parentSig</td><td>bytes</td><td>Referrer's signature or referrer's address.</td></tr><tr><td>onceSig</td><td>bytes</td><td>Invite code.</td></tr><tr><td>deadline</td><td>uint</td><td>Deadline of the invite code.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>id</td><td>uint</td><td>Id of the new agent.</td></tr></tbody></table>

### **sign**

Parent on-chain pre-sign for a referral code. This function serves as an on-chain pre-signing mechanism specifically designed for contract wallets. A contract wallet is required to provide its address as an argument to the digest parameter when invoking the sign function.&#x20;

```solidity
function sign(
    bytes32 digest) external
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>digest</td><td>bytes32</td><td>Digest of the referral code.</td></tr></tbody></table>

### **userInfo**

Retrieves user's agent data.

```solidity
function userInfo(
    address _owner) external view returns (address ref, uint gen)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>_owner</td><td>address</td><td>User's address.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>ref</td><td>address</td><td>Parent agent's owner address.</td></tr><tr><td>gen</td><td>uint</td><td>Generation of user's agent.</td></tr><tr><td></td><td></td><td></td></tr></tbody></table>

### **getAgent**

Retrieves agent data by user's id.

```solidity
function getAgent(
    uint id) external view returns (address, uint, uint, uint, uint[] memory)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>id</td><td>uint</td><td>Id of the user.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="100">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>owner</td><td>address</td><td>User's agent owner address.</td></tr><tr><td>gen</td><td>uint</td><td>Generation of user's agent.</td></tr><tr><td>birth</td><td>uint</td><td>Timestamp when the agent registered.</td></tr><tr><td>parentId</td><td>uint</td><td>Id of the agent's parent.</td></tr><tr><td>childrenId</td><td>uint[]</td><td>Ids of the agent's children.</td></tr></tbody></table>

