# Dyson Finance
## Contract Overview
- Core
  - Agency: 
    
    This contract manages the referral logic within Dyson Finance. If a user deposits in Pair and has registered in referral system, he will get extra DYSON token as reward. Each user in the referral system is an `Agent`. Referral of a agent is called the `child` of the agent.
  - ForeignAgency: 
    
    An extension of the "Agency" contract designed for a referral system on a foreign chain. It allows the admin to add agents who are not Tier 1 agents. Key features include adding new child agents to a root agent with specified generation and the number of slots used. 
  - AgentNFT: 
    
    AgentNFT is an extension of the Agency main contract and is fully ERC721 compatible. Users may only hold 1 NFT at a time. The NFT contract handles most of the business logic, with transfers directed back to the main contract's transfer function. Transferring agents can only be done via the AgentNFT contract.
  - Router: 
    
    Router serves as an entry point for swapping, depositing, and withdrawing. It helps users handle WETH wrap/unwrap issues and prevents token approval for multiple pairs. Users can deposit dual investments, swap, boost, and stake DYSON.
  - Pair: 
    
    Pair represents the pool contract in Dyson Finance. The full version supports WETH-USDC, WBTC-USDC, and DYSON-USDC pools upon launch.
  - Factory: 
    
    Factory is the contract that deploys DysonPair. Unlike Uniswap, Dyson allows multiple Pair instances for a trading pair of two tokens. A flag determines whether deploying a new pair is permissionless. Factory also serves as a beacon providing the current controller address for all pairs.
  - Farm: 
    
    This contract handles all business logic related to `Point` calculation.
  - Gauge: 
    
    Gauge is a voting contract for liquidity pools, with each liquidity pool having its own Gauge contract.
  - GaugeFactory: 
    
    GaugeFactory is the factory contract for Gauges.
  - Bribe: 
    
    Contract for third parties to bribe sDYSON holders into depositing their sDYSON in certain Gauge contract. Each Bribe contract is paired with one Gauge contract. Third parties can add multiple tokens as rewards.
  - BribeFactory: 
    
    BribeFactory is the factory contract for Bribe contracts.
  - DYSON: 
    
    DYSON is an ERC20 contract for the $DYSON token.
  - sDYSON: 
    
    sDYSON is an ERC20 contract for Staked $DYSON, supporting cross-chain transfers.
  - DysonToGo: 
    
    DysonToGo is a guild protocol built upon Dyson Finance, simplifying user investment processes. Non-members can participate and earn exclusive $DYSN mining rewards. Rewards are distributed among all guild members according to a specified ratio by the guild owner.
  - DysonToGoFactory: 
    
    DysonToGoFactory is the factory contract for DysonToGo.
- Utility
  - AddressBook: 
    
    AddressBook serves as a central registry for various addresses within the Dyson Finance ecosystem, managing important addresses and settings for the protocol.
  - FeeDistributor: 
    
    FeeDistributor receives fees from Pair and distributes them to the DAO wallet and Bribe. The owner can adjust the fee distribution rate to the DAO, the DAO wallet address, the Bribe contract address, and the associated pair.
  - ICO: 
    
    ICO is the contract for Initial Coin Offering, implementing a Dutch-style auction ICO for a specified token. Users can stake token0 or token1 and receive corresponding shares in the ICO token. The contract uses linear interpolation to calculate the current maxUnits during the ICO.
  - TokenSender: 
    
    TokenSender addresses security concerns in token transfers by allowing two token transfers in a single transaction, mitigating potential security attacks.
  - TreasuryVester: 
    
    TreasuryVester locks a certain amount of $DYSON reward tokens for a specific period, allowing the recipient to claim them after the vesting cliff date.
- Scripts
  - MainnetDeploy.s.sol
  
    This script deploys the full version of Dyson Finance.
  - MainnetDeployPart1.s.sol
    
    This script deploys the limited version of Dyson Finance. This version only supports swap and dual-investment in a single `WETH-USDC` pool. The contracts deployed at this stage includes `Factory`, `Router`, `AddressBook`, `Pair`(WETH-USDC), `DYSON`, `sDYSON` and `TokenSender`.
  - MainnetDeployPart2.s.sol
    
    This script deploys the rest of contracts in Dyson Finance. The contracts deployed at this stage includes `Agency`, `Farm`, `Pair`(DYSON-USDC), `Pair`(WBTC-USDC), the `feeDistributor`, `Gauge` and `Bribe` of each pool, serveral `TreasuryVester`s. After this deployment, it will become a full-version of Dyson Finance.
  - DysonToGoFactoryDeploy.s.sol
    
    This script deploys DysonToGoFactory for future deployment of DysonToGo.
  - DysonToGoDeploy.s.sol
    
    This script deploys the DysonToGo contract from DysonToGoFactory and sets up configuration for it.

## Testing
- Setup `.env`
    ```
    POLYGON_ZKEVM_RPC_KEY=""
    DEPLOYER_PRIVATE_KEY=""
    OWNER_ADDRESS=""
    ```
- Use the following commands to run tests in `src/test`.
    ```shell
    forge build
    forge test
    forge test -vv
    forge test -vvvv
    forge test --match-path src/test/Agency.t.sol
    ```

## Deployment
Enter the following command to run your target script:
```shell
forge script src/script/MainnetDeploy.s.sol:MainnetDeployScript
```
In an official deployment, execute the `deploy.sh` script and set the configuration parameters for compile version, optimizer runs, rpc url, target script, and broadcast:
```
% ./deploy.sh
Please enter Solidity compile version:0.8.17
Please enter Solidity optimizer runs:200
Please enter deploy rpc url:https://polygonzkevm-mainnet.g.alchemy.com/v2/your_key                        
Please select target script:
1: MainnetDeploy
2: MainnetDeployPart1
3: MainnetDeployPart2
4: DysonToGoFactoryDeploy
5: DysonToGoDeploy
Please enter target script:2
Is broadcast? (y/n):y
```
1. compile version, such as `0.8.17`.
2. optimizer runs, such as `200`.
3. rpc url, such as `https://polygonzkevm-mainnet.g.alchemy.com/v2/your_key`.
4. target script, such as `2`.
5. is broadcast or not, enter `y` or `n`. If `y`, all transactions in the script will execute on chain. Otherwise, it would only simulate on-chain transaction using on-chain data.

After deployment, it will print all logs in `log` file and all contract addresses in `config.json`.


## Deploy Flow
- Setup `.env`
    
    specify the deployer, project owner, polygon zkEVM rpc key, polygonscan key. (The official version will be deployed on Polygon zkEVM)
    ```
    DEPLOYER_PRIVATE_KEY=""
    OWNER_ADDRESS=""
    POLYGON_ZKEVMSCAN_KEY=""
    POLYGON_ZKEVM_RPC_KEY=""
    ```
- Stage 1: Dyson Finance Part1. (Pioneer Version)
    - Run `deploy.sh` with `MainnetDeployPart1.s.sol` script. Contract addresses will be automatically listed in `deploy-config.json` for next stage usage, and the owner will also be transferred to the project owner.
- Stage 2: Dyson Finance Part2. (Full version)
    - Project owner need to transfer the contract ownership of Factory, Router, AddressBook, DYSON and sDYSON to the new deployer.
    - Run `deploy.sh` with `MainnetDeployPart2.s.sol` script using the new deployer. This part2 script will reference the contract addresses in `deploy-config.json` which deployed at part1.

- Stage 3: TreasuryVester 
  - Set up the `TreasuryRecipients` list and their corresponding `TreasuryAmounts` list in `deploy-config.json`. 
  - Project owner must transfer the contract ownership of `DYSON` to the new deployer.
  - Run `deploy.sh` with `TreasuryVesterDeploy.s.sol` script using the new deployer. This script will reference the `TreasuryRecipients`, `TreasuryAmounts`, `DYSON` and `sDYSON` addresses in `deploy-config.json` which have been set at previous stage.
- Stage 4: DysonToGoFactory
    - Run deploy.sh with DysonToGoFactoryDeploy.s.sol script using the new deployer. Once the deployment is done, the address of `DysonToGoFactory` will be listed in `deploy-config.json` for next stage usage.
- Stage 5: DysonToGo
    - Set up `.env`:
    We need to use the controller of DysonToGoFactory to deploy `DysonToGo`.
    ```
    TOGO_FACTORY_CONTROLLER_PRIVATEKEY=""
    ```
    - Set up `relyGauges` list, `relyPairs` list and `toGoOwner` in `deploy-config.json`.
    - Run deploy.sh with DysonToGoDeploy.s.sol script using the controller of DysonToGoFactory.