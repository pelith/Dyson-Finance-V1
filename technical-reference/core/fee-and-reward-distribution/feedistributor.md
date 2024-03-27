# FeeDistributor

FeeDistributor receives fees from Pair and distributes them to the DAO wallet and Bribe. The owner can adjust the fee distribution rate to the DAO, the DAO wallet address, the Bribe contract address, and the associated pair.

### setFeeRateToDao

Allows the owner to set the fee rate for DAO.

```solidity
function setFeeRateToDao(
    uint _feeRateToDao) external onlyOwner
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>_feeRateToDao</td><td>uint</td><td>New fee rate for DAO, stored in 1e18.</td></tr></tbody></table>



### setDaoWallet

Allows the owner to set the DAO wallet address.

```solidity
function setDaoWallet(
    address _daoWallet) external onlyOwner
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>_daoWallet</td><td>address</td><td>New address for the DAO wallet.</td></tr></tbody></table>

### setBribe

Allows the owner to set the Bribe contract address.

```solidity
function setBribe(
    address _bribe) external onlyOwner
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>_bribe</td><td>address</td><td>New address for the Bribe contract.</td></tr></tbody></table>

### setPair

Allows the owner to set the DysonPair contract address, along with the corresponding pair tokens.

```solidity
function setPair(
    address _pair) external onlyOwner
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>_pair</td><td>address</td><td>New address for the DysonPair contract.</td></tr></tbody></table>

### distributeFee

Distributes fees collected from the DysonPair to the DAO wallet and Bribe according to the feeRateToDao.

```solidity
function distributeFee() external
```

### \_calculateFee

Internal function to calculate the fee distribution to DAO and Bribe for a given token.

```solidity
function _calculateFee(
    address _token) internal view returns (uint feeToDAO, uint feeToBribe)
```

Parameters:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>_token</td><td>address</td><td>Address of the token.</td></tr></tbody></table>

Return Values:

<table><thead><tr><th width="191">Name</th><th width="92">Type</th><th width="279">Description</th></tr></thead><tbody><tr><td>feeToDAO</td><td>uint</td><td>Fee amount to be sent to the DAO.</td></tr><tr><td>feeToBribe</td><td>uint</td><td>Fee amount to be sent to the Bribe contract.</td></tr></tbody></table>
