# Perform a Dual Investment Withdrawal

## Executing a Dual Investment Withdrawal: Two Approaches&#x20;

Once the lock time concludes, you can withdraw your dual investment position to reclaim your tokens. There are two methods available for initiating a withdrawal, each with its own distinct advantages. The first method involves direct interaction with the Pair contract, while the second utilizes the Router contract. The primary distinction lies in the fact that the second method can facilitate the withdrawal of ETH, wherein the Router converts ETH to WETH before executing the actual withdraw. Additionally, the Router supports `withdrawMultiPositions`, enabling users to withdraw their positions in a single transaction. This section will provide guidance on both options.

### 1. Direct Withdraw within Pair Contract&#x20;

You can simply call `withdraw` to withdraw your dual investment position and receive either one of token0 or token1.

```solidity
// Pair.sol
function withdraw(
    uint index, 
    address to) external lock returns (uint token0Amt, uint token1Amt)
```

Parameters:

* `index` : Index of the `note` owned by user.
* `to` : Address to receive the redeemed token0 or token1.

Return Values:

* `token0Amt` : Amount of token0 withdrawn.
* `token1Amt` : Amount of token1 withdrawn.

Alternatively, you can withdraw a position on behalf of another address, granted approval by the respective address. In this scenario, the owner of the position needs to invoke the `setApprovalForAll` function to approve your address for position withdrawal. Subsequently, you can utilize the `withdrawFrom` function to withdraw their position on their behalf. While originally designed for the Router to manage dual investment positions on behalf of users, you can also employ this function for other purposes as necessary.

```solidity
// Pair.sol
function setApprovalForAll(
    address operator, 
    bool approved) external
```

Parameters:

* `operator` : Address of the operator.
* `approved` : Whether the operator is approved or not.

```solidity
// Pair.sol
function withdrawFrom(
    address from, 
    uint index, 
    address to) external returns (uint token0Amt, uint token1Amt)
```

Parameters:

* `from` : Address of the user who owns the position.
* `index` : Index of the note.
* `to` : Address to receive the redeemed token0 or token1.

Return Value:

* `token0Amt` : Amount of token0 withdrawn.
* `token1Amt` : Amount of token1 withdrawn.

#### Set Up your  Contract

* Declare the solidity version used to compile the contract.
* Import the IPair interface.
* Write your own contract, here we name it `MyWithdrawTest`.&#x20;

<pre class="language-solidity"><code class="lang-solidity">// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
<strong>
</strong>interface IPair {
    function withdraw(uint index, address to) external returns (uint token0Amt, uint token1Amt);
    function withdrawFrom(address from, uint index, address to) external returns (uint token0Amts, uint token1Amts);
    function setApprovalForAll(address operator, bool approved) external;
}

contract MyWithdrawTest {
    // The DYSON-USDC pair contract on Polygon zkEVM. 
    // In this pair, the token0 represents $DYSN and token1 represents $USDC.
    address dysonUsdcPair = 0xC9001AFF3701e19C29E996D48e474Baf4C5eD006;
    // The $DYSN contract on Polygon zkEVM.
    address public constant DYSN = 0x9CBD81b43ba263ca894178366Cfb89A246D1159C;
    // The $USDC contract on Polygon zkEVM.
    address public constant USDC = 0xA8CE8aee21bC2A48a5EF670afCc9274C7bbbC035;
    
    function withdraw(uint index, address to) external returns (uint token0Amt, uint token1Amt) {
        return IPair(dysonUsdcPair).withdraw(index, to);
    }
    
    // If pre-approved by `from`, you have the option to utilize this function to withdraw the position on their behalf.
    function withdrawFrom(address from, uint index, address to) external returns (uint token0Amts, uint token1Amts) {
        return IPair(dysonUsdcPair).withdrawFrom(from, index, to);
    }
}
</code></pre>

### 2. Withdraw through Router Contract&#x20;

Alternatively, you have the option to initiate a withdrawal through the Router contract. It's important to note that as the Router will be withdrawing the position on your behalf, you need to sign a signature and pre-approve the router for position withdrawal by calling `setApprovalForAllWithSig` for the pair. Details regarding the signature process will be explained later. Now, let's examine the withdrawal functions below.

#### withdraw

```solidity
// Router.sol
function withdraw(
    address pair, 
    uint index, 
    address to) external returns (uint token0Amt, uint token1Amt)
```

Parameters:

* `pair` : The address of a specific pair contract.
* `index` : Index of the note to withdraw.
* `to` : Address that will receive either token0 or token1.

Return Value:

* `token0Amt` : Amount of token0 withdrawn.
* `token1Amt` : Amount of token1 withdrawn.

#### withdrawETH

The `withdrawETH` function is specifically crafted for scenarios where either token0 or token1 in the pair is WETH. This is because the Router will handle the conversion of your WETH to ETH and subsequently return it to you. If you opt for the regular withdrawal, you would receive WETH instead of ETH.

```solidity
// Router.sol
function withdrawETH(
    address pair, 
    uint index, 
    address to) external returns (uint token0Amt, uint token1Amt);
```

Parameters:

* `pair` : The address of a specific pair contract.
* `index` : Index of the note to withdraw.
* `to` : Address that will receive either token0 or token1 (One of them would be ETH).

Return Value:

* `token0Amt` : Amount of token0 withdrawn.
* `token1Amt` : Amount of token1 withdrawn.

#### withdrawMultiPositions

If you find yourself needing to withdraw multiple positions and prefer not to do so individually, employing the `withdrawMultiPositions` function is an efficient approach. This function enables you to withdraw all your positions across various pairs in a single transaction.

```solidity
// Router.sol
function withdrawMultiPositions(
    address[] calldata pairs, 
    uint[] calldata indexes, 
    address[] calldata tos) external returns (uint[] memory token0Amounts, uint[] memory token1Amounts);
```

Parameters:

* `pairs` : Array of `Pair` contract addresses.
* `indexes` : Array of index of the note to withdraw.
* `tos` : Array of address that will receive either token0 or token1.

Return Values:

* `token0Amounts` : Array of amount of token0 withdrawn.
* `token1Amounts` : Array of amount of token1 withdrawn.

#### Approve Router for withdrawal with signature

Regardless of whether you opt for `withdraw`, `withdrawETH`, or `withdrawMultiPositions`, it's essential to pre-approve the Router for withdrawal on your behalf using `setApprovalForAllWithSig`. To illustrate, consider the following scenario: A user Alice intends to withdraw three positions with note IDs 23 and 106 in Pair 1, and note ID 14 in Pair 2. The flow chart below outlines the process:

<figure><img src="../../.gitbook/assets/image (17).png" alt=""><figcaption><p>This graph illustrates the flow of withdrawing dual investment positions through Router contract.</p></figcaption></figure>

Highlighting a crucial detail, we implement [EIP-712](https://eips.ethereum.org/EIPS/eip-712), a standard for hashing and signing typed structured data, in our approval process. The provided code snippets below will demonstrate how to utilize the Foundry library to simulate signing that aligns with the EIP-712 standard.

#### Set Up your Contract

* Declare the solidity version used to compile the contract.
* Import IRouter interface.
* This time, create your own contract by using the Foundry testing library, particularly `forge-std/Test.sol`. Check out the code snippets below where we make use of [`vm.addr()`](https://book.getfoundry.sh/cheatcodes/addr) and [`vm.sign()`](https://book.getfoundry.sh/cheatcodes/sign) to easily sign approval messages during testing.

```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import "forge-std/Test.sol";

interface IRouter {
    function setApprovalForAllWithSig(address pair, bool approved, uint deadline, bytes calldata sig) external;
    function withdraw(address pair, uint index, address to) external returns (uint token0Amt, uint token1Amt);
    function withdrawETH(address pair, uint index, address to) external returns (uint token0Amt, uint token1Amt);
    function withdrawMultiPositions(address[] calldata pairs, uint[] calldata indexes, address[] calldata tos) external returns (uint[] memory token0Amounts, uint[] memory token1Amounts);
    function multicall(bytes[] calldata data) external returns (bytes[] memory results);
}

interface IPair {
    function nonces(address user) external view returns (uint);
}

contract MyWithdrawTest is Test {
    // The Router contract on Polygon zkEVM.
    address public constant router = 0xADa6e69781399990d42bEcB1a9427955FFA73Bdc;
    
    // EIP712: TYPEHASH for signing for setApprovalForAllWithSig.
    bytes32 constant APPROVE_TYPEHASH = keccak256("setApprovalForAllWithSig(address owner,address operator,bool approved,uint256 nonce,uint256 deadline)");
    
    // Alice's wallet private key
    uint aliceKey = 123456;
    // Alice's wallet address
    address alice = 0x1234....;
    uint deadline = block.timestamp + 1;
    
    function withdraw(address pair, uint index) external returns (uint token0Amt, uint token1Amt) {
        bytes memory sig = _getApprovalSig(pair, aliceKey, true, deadline);
        IRouter(router).setApprovalForAllWithSig(pair, true, deadline, sig);
        (token0Amt, token1Amt) = IRouter(router).withdraw(pair, index, alice);
    }
    
    function withdrawETH(address pair, uint index) external returns (uint token0Amt, uint token1Amt) {
        bytes memory sig = _getApprovalSig(pair, aliceKey, true, deadline);
        IRouter(router).setApprovalForAllWithSig(pair, true, deadline, sig);
        (token0Amt, token1Amt) = IRouter(router).withdrawETH(pair, index, alice);
    }
    
    // Just like the scenario above, Alice intends to withdraw three positions 
    // with note IDs 23 and 106 in Pair 1, and note ID 14 in Pair 2.
    address public pair1 = 0x5678....;
    address public pair2 = 0x6789....;
    
    function withdrawMultiPositions() external returns (uint[] memory token0Amounts, uint[] memory token1Amounts) {
        bytes memory sig = _getApprovalSig(pair1, aliceKey, true, deadline);
        bytes memory sig2 = _getApprovalSig(pair2, aliceKey, true, deadline);

        bytes[] memory data = new bytes[](2);
        data[0] = abi.encodeWithSelector(IRouter.setApprovalForAllWithSig.selector, pair1, true, deadline, sig);
        data[1] = abi.encodeWithSelector(IRouter.setApprovalForAllWithSig.selector, pair2, true, deadline, sig2);
        
        // Use multical to set approval for all pools
        IRouter(router).multicall(data);        

        address[] memory pairs = new address[](3);
        pairs[0] = pair1;
        pairs[1] = pair1;
        pairs[2] = pair2;
    
        uint[] memory indexes = new uint[](3);
        indexes[0] = 23;
        indexes[1] = 106;
        indexes[2] = 14;

        address[] memory tos = new address[](4);
        for(uint i=0; i < 3; i++) {
            tos[i] = alice;
        }

        (token0Amounts, token1Amounts) = IRouter(router).withdrawMultiPositions(pairs, indexes, tos);
    }
    
    // Internal function for signing an approval.
    function _getApprovalSig(address pair, uint fromKey, bool approved, uint _deadline) private view returns (bytes memory) {
        address fromAddr = vm.addr(fromKey);
        bytes32 structHash = keccak256(abi.encode(APPROVE_TYPEHASH, fromAddr, address(router), approved, IPair(pair).nonces(fromAddr), _deadline));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", _getPairDomainSeparator(pair), structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(fromKey, digest);
        return abi.encodePacked(r, s, v);
    }
    
    // Internal function for acquiring domain separator.
    function _getPairDomainSeparator(address pair) private view returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes("Pair")),
                keccak256(bytes('1')),
                block.chainid,
                pair
            )
        );
    }
}
```
