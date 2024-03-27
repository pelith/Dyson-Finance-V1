# Boost the Pool by depositing your $sDYSN

## Executing a Boost

As mentioned in previous section, holders can deposit their $sDYSN into the Gauge contract to enhance a corresponding pool's reward generation speed. Explore the [Gauge & Yield Boosting](https://docs.dyson.finance/mechanisms/gauge-and-yield-boosting) section in our white paper for further insights into boosting opportunities.

Two main methods initiate boosting: direct interaction with the Gauge contract or utilizing the Router contract. However, as the Router interaction is equivalent to the Gauge contract, boosting through Router is unnecessary unless you have a specific goal of consolidating multiple interactions into a single transaction. Here, we'll only introduce the boosting method within Gauge.

### Boost within Gauge Contract&#x20;

<pre class="language-solidity"><code class="lang-solidity"><strong>// Gauge.sol
</strong><strong>function deposit(
</strong><strong>    uint amount, 
</strong><strong>    address to) external;
</strong></code></pre>

Parameters:

* `amount` : Amount of sGov token.
* `to` : Address that owns the amount of sGov token.

#### Set Up your Contract

<pre class="language-solidity"><code class="lang-solidity">// SPDX-License-Identifier: UNLICENSED
<strong>pragma solidity 0.8.17;
</strong>
interface IERC20 {
    function approve(address spender, uint value) external returns (bool);
}

interface IGauge {
    function deposit(uint amount, address to) external;
}

contract MyBoostTest {
    // The DYSON-USDC Gauge contract on Polygon zkEVM.
    address public constant gauge = 0x7bC034759Cc6582926773b1094A7bEf406c2376D;
    // The sDYSON contract on Polygon zkEVM.
    address public constant sDYSON = 0x8813B3EEB279A43Ac89e502e6fbe0ec89170c088;

    uint amount = 100e18; // 100 $sDYSN
    address to = address(this);

    function boost() external {
        IERC20(sDYSON).approve(gauge, amount);
        IGauge(gauge).deposit(amount, to);
    }
}
</code></pre>
