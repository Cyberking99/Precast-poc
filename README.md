# LMSR Prediction Market (PoC)

A Proof of Concept implementation of a Prediction Market using the **Logarithmic Market Scoring Rule (LMSR)** algorithm on Ethereum, built with [Foundry](https://getfoundry.sh/).

## Overview

This project implements a binary prediction market (YES/NO) where share prices are determined by an automated market maker (AMM) using the LMSR cost function. This ensures:
- **Infinite Liquidity**: The market maker is always willing to trade.
- **Path Independence**: The cost to reach a state is the same regardless of the order of trades.
- **Bounded Loss**: The market maker's maximum loss is bounded by the liquidity parameter $b$.

## The Math

The core of the market is the **Cost Function**:

$$ C(q) = b \cdot \ln(e^{q_{YES}/b} + e^{q_{NO}/b}) $$

Where:
- $C(q)$: Total cost of the market state.
- $q_{YES}, q_{NO}$: Total quantity of shares sold for each outcome.
- $b$: Liquidity parameter (determines price sensitivity).

**Price Calculation:**
The instantaneous price of a share is the derivative of the cost function:
$$ P_{YES} = \frac{e^{q_{YES}/b}}{e^{q_{YES}/b} + e^{q_{NO}/b}} $$

**Trade Cost:**
The cost to buy a specific amount of shares is the difference in the total cost function before and after the trade:
$$ \text{Cost} = C(q_{new}) - C(q_{old}) $$

**Maximum Loss (Subsidy):**
The maximum possible loss for the market maker is $b \cdot \ln(2)$. This is the "initial cost" or funding required to start the market.

## Implementation Details

- **Language**: Solidity ^0.8.13
- **Math Library**: [PRBMath](https://github.com/PaulRBerg/prb-math) (v4)
    - Uses `UD60x18` (Unsigned Decimal 60.18-fixed-point) for high-precision arithmetic.
    - Replaces standard `uint256` math to handle complex logarithmic (`ln`) and exponential (`exp`) operations.

## Setup & Usage

### Prerequisites
- [Foundry](https://book.getfoundry.sh/getting-started/installation)

### Installation
1. Clone the repository.
2. Install dependencies:
   ```bash
   forge install
   ```

### Running Tests
We have a comprehensive test suite in `test/LMSRPredictionMarket.t.sol` verifying the cost function logic.

```bash
forge test
```

**Test Cases:**
- `testInitialCost`: Verifies the initial market cost matches $b \cdot \ln(2)$.
- `testInitialCostWith100Liquidity`: Verifies the math holds for different liquidity parameters (e.g., $b=100$).
- `testCostAfterBuying10Yes`: Verifies the cost calculation after simulated trades.
- `testCostIncreasesWithShares`: Ensures buying shares always increases the cost (monotonicity).

## Project Structure

```
├── src
│   └── LMSRPredictionMarket.sol  # Main contract implementing LMSR logic
├── test
│   └── LMSRPredictionMarket.t.sol # Tests for verification
├── lib                           # Dependencies (forge-std, prb-math)
├── foundry.toml                  # Configuration
└── remappings.txt                # Dependency path mappings
```

## Configuration

The market is initialized with a **liquidity parameter** `b`.
- **Higher `b`**: More liquidity, stable prices (good for high volume).
- **Lower `b`**: Less liquidity, prices move fast (good for low volume, cheaper to fund).

Example initialization:
```solidity
// Create market with b = 1000 ether
new LMSRPredictionMarket(1000 ether);
```

## References
- [Logarithmic Market Scoring Rule (Robin Hanson)](https:// Hanson.gmu.edu/mktscore.pdf)
- [PRBMath Documentation](https://github.com/PaulRBerg/prb-math)
