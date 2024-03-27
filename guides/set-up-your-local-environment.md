# Set Up Your Local Environment

There are plenty popular development toolsets such as Hardhat and [Foundry](https://book.getfoundry.sh/). In Dyson Finance repo, we use [Foundry](https://book.getfoundry.sh/) as the tool to develop and test our contracts.

### Get Started

```
git clone https://github.com/DysonFinance/Dyson-Finance-V1.git
```

### Install Foundry

```
// Install foundryup
$ curl -L https://foundry.paradigm.xyz | bash

// Install or update Foundry
$ foundryup
```

### Compile All Contracts

```
$ forge build
```

### Testing

You can look up our tests to know more about the integration.

To run tests, you can follow the steps below:

*   Setup `.env`

    ```
    POLYGON_ZKEVM_RPC_KEY=""
    DEPLOYER_PRIVATE_KEY=""
    OWNER_ADDRESS=""
    ```
*   Use the following commands to run tests in `src/test`.

    ```shell
    forge test
    forge test -vv
    forge test -vvvv
    forge test --match-path src/test/xxx.t.sol
    ```
