# Overview

## Contracts Overview

<figure><img src="../.gitbook/assets/image (27).png" alt=""><figcaption><p>This diagram serves as an informative tool to elucidate the responsibilities of each contract regarding variables, as well as highlight crucial function calls that transpire between these contracts.</p></figcaption></figure>

*   Router:

    Router serves as an entry point for swapping, depositing, and withdrawing. It helps users handle WETH wrap/unwrap issues and prevents token approval for multiple pairs. Users can deposit dual investments, swap, boost, and stake DYSON.
*   Pair:

    Pair represents the pool contract in Dyson Finance. The full version supports WETH-USDC, WBTC-USDC, and DYSON-USDC pools upon launch.
*   DYSON:

    DYSON is an ERC20 contract for the $DYSON token.
*   AddressBook:

    AddressBook serves as a central registry for various addresses within the Dyson Finance ecosystem, managing important addresses and settings for the protocol.
* Membership
  *   Agency:

      This contract manages the referral logic within Dyson Finance. If a user deposits in Pair and has registered in referral system, he will get extra DYSON token as reward. Each user in the referral system is an `Agent`. Referral of a agent is called the `child` of the agent.
  *   AgentNFT:

      AgentNFT is an extension of the Agency main contract and is fully ERC721 compatible. Users may only hold 1 NFT at a time. The NFT contract handles most of the business logic, with transfers directed back to the main contract's transfer function. Transferring agents can only be done via the AgentNFT contract.
  *   ForeignAgency:

      An extension of the "Agency" contract designed for a referral system on a foreign chain. It allows the admin to add agents who are not Tier 1 agents. Key features include adding new child agents to a root agent with specified generation and the number of slots used.
* Factories
  *   PairFactory:

      Factory is the contract that deploys Pair. Unlike Uniswap, Dyson allows multiple Pair instances for a trading pair of two tokens. A flag determines whether deploying a new pair is permissionless. Factory also serves as a beacon providing the current controller address for all pairs.
  *   GaugeFactory:

      GaugeFactory is the factory contract for Gauges.
  *   BribeFactory:

      BribeFactory is the factory contract for Bribe contracts.
* Staking & Yield Boosting
  *   Farm:

      This contract handles all business logic related to `Point` calculation.
  *   Gauge:

      Gauge is a voting contract for liquidity pools, with each liquidity pool having its own Gauge contract.
  *   sDYSON:

      sDYSON is an ERC20 contract for Staked $DYSON, supporting cross-chain transfers.
* Fee & Reward Distribution
  *   Bribe:

      Contract for third parties to bribe sDYSON holders into depositing their sDYSON in certain Gauge contract. Each Bribe contract is paired with one Gauge contract. Third parties can add multiple tokens as rewards.
  *   FeeDistributor:

      FeeDistributor receives fees from Pair and distributes them to the DAO wallet and Bribe. The owner can adjust the fee distribution rate to the DAO, the DAO wallet address, the Bribe contract address, and the associated pair.
