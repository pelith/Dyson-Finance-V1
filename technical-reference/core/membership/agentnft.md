# AgentNFT

AgentNFT is an extension of the Agency main contract and is fully ERC721 compatible. Users may only hold 1 NFT at a time. The NFT contract handles most of the business logic, with transfers directed back to the main contract's transfer function. Transferring agents can only be done via the AgentNFT contract.

### **supportsInterface**

Checks if the contract supports a given interface. Interface identification is specified in ERC-165.

```solidity
function supportsInterface(
    bytes4 interfaceID) external pure returns (bool)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>interfaceID</td><td>bytes4</td><td>Interface ID to check.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>None</td><td>bool</td><td>True if the contract supports the interface.</td></tr></tbody></table>

### **tokenURI**

Retrieves metadata for a specified token ID, including owner, tier, birth, and parent details from the `Agency` contract, and calls`_tokenURI` .

```solidity
function tokenURI(
    uint tokenId) external view returns (string memory)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>tokenId</td><td>uint</td><td>ID of the token.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>None</td><td>string</td><td>Token URI.</td></tr></tbody></table>

### \_tokenURI

Internal function to construct the token URI. It constructs an SVG image with this information and encodes it into Base64. The resulting Base64 string is embedded in a JSON format, forming the final URI. This URI provides detailed information for displaying the NFT, such as name, description, and image, serving external applications or services.

```solidity
function _tokenURI(
    uint tokenId, 
    uint parent, 
    uint tier, 
    uint birth) internal pure returns (string memory output)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>tokenId</td><td>uint</td><td>ID of the token.</td></tr><tr><td>parent</td><td>uint</td><td>ID of the parent.</td></tr><tr><td>tier</td><td>uint</td><td>Tier of the agent.</td></tr><tr><td>birth</td><td>uint</td><td>Timestamp of the agent's creation.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>output</td><td>string</td><td>Token URI.</td></tr></tbody></table>

### **totalSupply**

Returns the total number of tokens.

```solidity
function totalSupply() external view returns (uint)
```

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>None</td><td>uint</td><td>Total supply of tokens.</td></tr></tbody></table>

### **balanceOf**

Returns the balance of tokens for a given owner.

```solidity
function balanceOf(
    address owner) external view returns (uint balance)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>owner</td><td>address</td><td>Address of the token owner.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>balance</td><td>uint</td><td>Token balance of the owner.</td></tr></tbody></table>

### **ownerOf**

Returns the owner of a given token.

```solidity
function ownerOf(
    uint tokenId) public view returns (address owner)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>tokenId</td><td>uint</td><td>ID of the token.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>owner</td><td>address</td><td>Owner address of the token.</td></tr></tbody></table>

### **onMint**

Invoked by the `Agency` contract during the minting of a new token, its sole purpose is to emit the Transfer event.

```solidity
function onMint(
    address user, 
    uint tokenId) external
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>user</td><td>address</td><td>Address of the user receiving the token.</td></tr><tr><td>tokenId</td><td>uint</td><td>ID of the minted token.</td></tr></tbody></table>

### safeTransferFrom

Safely transfers a token from one address to another. This function simply calls the other `safeTransferFrom` with the bytes data `''`.

```solidity
function safeTransferFrom(
    address from,
    address to,
    uint tokenId) external
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>from</td><td>address</td><td>Address of the sender.</td></tr><tr><td>to</td><td>address</td><td>Address of the receiver.</td></tr><tr><td>tokenId</td><td>uint</td><td>ID of the token.</td></tr></tbody></table>

### approve

Approves an address to manage the specified token.

```solidity
function approve(
    address to, 
    uint tokenId) external
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>to</td><td>address</td><td>Address to be approved.</td></tr><tr><td>tokenId</td><td>uint</td><td>ID of the token.</td></tr></tbody></table>

### setApprovalForAll

Sets or revokes approval for an operator to manage all tokens of the sender.

```solidity
function setApprovalForAll(
    address operator, 
    bool approved) external
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>operator</td><td>address</td><td>Address of the operator.</td></tr><tr><td>approved</td><td>bool</td><td>Approval status.</td></tr></tbody></table>

### transferFrom

Transfers a token from one address to another.

```solidity
function transferFrom(
    address from,
    address to,
    uint tokenId) external
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>from</td><td>address</td><td>Address of the sender.</td></tr><tr><td>to</td><td>address</td><td>Address of the receiver.</td></tr><tr><td>tokenId</td><td>uint</td><td>ID of the token.</td></tr></tbody></table>

### \_isContract

Internal function to check if an address is a contract. It checks if the provided address corresponds to a smart contract by examining its bytecode size. It returns `true` if the size is greater than zero; otherwise, it returns `false`.

```solidity
function _isContract(
    address account) internal view returns (bool)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>account</td><td>address</td><td>Address to check.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>None</td><td>bool</td><td>True if the address is a contract.</td></tr></tbody></table>

### **safeTransferFrom**

Facilitates the secure transfer of an ERC721 token from one address (`from`) to another (`to`). It invokes the internal `_transferFrom` function, updating token ownership. If the recipient (`to`) is a smart contract, it checks whether it implements the `IERC721Receiver` interface. If implemented, it calls the `onERC721Received` function, ensuring the expected selector is returned. Any deviation or failure is appropriately handled, providing robust and safe token transfers in ERC721-compliant contracts.

```solidity
function safeTransferFrom(
    address from,
    address to,
    uint tokenId,
    bytes memory data) public 
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>from</td><td>address</td><td>Address of the sender.</td></tr><tr><td>to</td><td>address</td><td>Address of the receiver.</td></tr><tr><td>tokenId</td><td>uint</td><td>ID of the token.</td></tr><tr><td>data</td><td>bytes</td><td>Additional data.</td></tr></tbody></table>

