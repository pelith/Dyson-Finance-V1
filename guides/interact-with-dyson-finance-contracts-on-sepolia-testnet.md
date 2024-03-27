# Interact with Dyson Finance contracts on Sepolia testnet

## Getting Started&#x20;

The Alpha version of Dyson Finance contracts operates on Sepolia testnet. To interact with Dyson Finance, you may need some tokens and NFT for testing. You can get these tokens via Faucet.

Faucet contract: `0x889a28163f08CdCF079C0692b23E4C586e811889`

### claimToken

The `msg.sender` of this call will receive 10000 $DYSN, 25000 $USDC and 1 $WBTC for test usage.&#x20;

```solidity
function claimToken() external 
```

Utilize these tokens for swapping within pairs or engage in a dual investment deposit to pairs. Further insights can be gleaned by reading the information presented in the following sections.

### claimAgent

The `msg.sender` of this call will receive a Tier1 Agent NFT.&#x20;

```solidity
function claimAgent() external
```

After receiving the NFT, you can check your NFT information through the following steps:

1. Get your NFT ID by calling the mapping `whois`  in Agent contract with your address.

```solidity
mapping(address => uint) public whois
```

2. Retrieve detailed information about your NFT by invoking the `getAgent` function with your NFT ID. The returned values include the agent owner, agent tier number, agent birth timestamp, agent parent ID, and an array of agent children IDs in sequence.

```solidity
function getAgent(uint id) external view returns (address, uint, uint, uint, uint[] memory)
```

3. To solely inquire about your parent address and tier number, a direct call to the `userInfo` function with your address in the Agent contract will suffice.

```solidity
function userInfo(address _owner) external view returns (address ref, uint gen)
```



## Deployment Addresses on Sepolia testnet

<table><thead><tr><th width="261">Contract</th><th>Address</th></tr></thead><tbody><tr><td>Faucet</td><td>0x889a28163f08CdCF079C0692b23E4C586e811889</td></tr><tr><td>DYSON-USDC Pair</td><td>0xd0f3c7d3d02909014303d13223302eFB80A29Ff3</td></tr><tr><td>WETH-USDC Pair</td><td>0xa28d7Dd51144426557afF3Db67d285d76c127d20</td></tr><tr><td>WBTC-USDC Pair</td><td>0xaCcb2A1DA03219C4398517F7761ef3538D6D90E5</td></tr><tr><td>AddressBook</td><td>0x65C4FfB47ffEE6bb351815DfCa5e197D71e1c82a</td></tr><tr><td>Agency</td><td>0x31894c572496Ce5Ab52DE4bC0e9964Db787744cD</td></tr><tr><td>AgentNFT</td><td>0x98e6Ee006cf13c2141Bc2Dfde0430b5E853CB5D8</td></tr><tr><td>DYSON</td><td>0xeDC2B3Bebbb4351a391363578c4248D672Ba7F9B</td></tr><tr><td>sDYSON</td><td>0xdDE61e3Ce99fAAFAF5ee63321e9e123B4cA313b6</td></tr><tr><td>Factory</td><td>0xb56b317345Be4757FeccaA08DbF82A82850Ff978</td></tr><tr><td>GaugeFactory</td><td>0x5cDd71dfb709f9972faff553079ff127caf7d4E2</td></tr><tr><td>BribeFactory</td><td>0x8066749B54e1E465F84FF5a5707e6FAd8a4C6b9d</td></tr><tr><td>Router</td><td>0x0E802CAbD4C20d8A24a2c98a4DA176337690cc0d</td></tr><tr><td>Farm</td><td>0x09E1c1C6b273d7fB7F56066D191B7A15205aFcBc</td></tr><tr><td>Gauge of DYSON-USDC Pair</td><td>0xe019f7c2783EA853D8ca75a2a3a5d6F171F307D1</td></tr><tr><td>Bribe of DYSON-USDC Pair</td><td>0xf24B9f2Ec84c557cB6432b5bC5Ae4207945025Ff</td></tr><tr><td>Gauge of WETH-USDC Pair</td><td>0x410740FD128E34AAc839E971545899E6a3707E92</td></tr><tr><td>Bribe of WETH-USDC Pair</td><td>0xb35A657a2e825326978ca9C0Fa812Ae4D54cC8f7</td></tr><tr><td>Gauge of WBTC-USDC Pair</td><td>0x54617a860eB2E3dfBC94Db1D51fAF5388e0A0bd4</td></tr><tr><td>Bribe of WBTC-USDC Pair</td><td>0xE97D7306Ed5988b6d45f073d4bf303b1724612ec</td></tr></tbody></table>
