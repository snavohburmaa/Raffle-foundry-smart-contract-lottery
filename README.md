# 🎰 Foundry Raffle

A decentralized raffle smart contract using Chainlink VRF for provably fair random winner selection and Chainlink Automation for automated execution.

## Overview

Automated lottery system that:
- Accepts entries via entrance fee
- Automatically selects random winner using Chainlink VRF
- Distributes entire contract balance to winner
- Uses Chainlink Keepers to trigger winner selection at intervals

**States**: `OPEN` (accepting entries) → `CALCULATING` (selecting winner)

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- For testnet/mainnet: Chainlink VRF subscription at [vrf.chain.link](https://vrf.chain.link/), LINK tokens, and ETH

## Installation

```bash
git clone <repository-url>
cd foundry-lottery
make install
make update
```

## Usage

```bash
make build      # Compile contracts
make test       # Run tests
make format     # Format code
make snapshot   # Gas snapshots
make anvil      # Start local node
```

## Deployment

### Local (Anvil)
```bash
make anvil      # Terminal 1
make deploy     # Terminal 2
```

### Sepolia Testnet
1. Create `.env` with `SEPOLIA_RPC_URL`, `PRIVATE_KEY`, `ETHERSCAN_API_KEY`
2. Create VRF subscription at [vrf.chain.link](https://vrf.chain.link/)
3. Update `HelperConfig.s.sol` with subscription ID
4. Deploy:
```bash
make deploy ARGS="--network sepolia"
make addConsumer ARGS="--network sepolia"      # If needed
make fundSubscription ARGS="--network sepolia"  # If needed
```

## Contract Functions

**Main Functions:**
- `enterRaffle()` - Enter raffle (pay entrance fee)
- `checkUpkeep()` - Check if upkeep needed (Chainlink Keepers)
- `performUpkeep()` - Trigger VRF request
- `fulfillRandomWords()` - VRF callback (selects winner)

**Getters:** `getRaffleState()`, `getRecentWinner()`, `getNumberOfPlayers()`, `getEntranceFee()`, etc.

**Events:** `RaffleEnter`, `RequestedRaffleWinner`, `WinnerPicked`

## Testing

```bash
make test
forge test --match-path test/unit/RaffleTest.t.sol
forge test --match-path test/integration/Interactions.t.sol
```

## Project Structure

```
src/Raffle.sol                 # Main contract
script/DeployRaffle.s.sol      # Deployment script
script/HelperConfig.s.sol      # Network config
test/unit/RaffleTest.t.sol     # Unit tests
test/integration/              # Integration tests
```

## Makefile Commands

| Command | Description |
|---------|-------------|
| `make install` | Install dependencies |
| `make build` | Build contracts |
| `make test` | Run tests |
| `make deploy` | Deploy (local) |
| `make deploy ARGS="--network sepolia"` | Deploy to Sepolia |
| `make anvil` | Start local node |

## Documentation

- [Foundry Book](https://book.getfoundry.sh/)
- [Chainlink VRF v2.5](https://docs.chain.link/vrf/v2-5/getting-started)
- [Chainlink Automation](https://docs.chain.link/chainlink-automation/introduction)

## License

MIT

## Author

Ohburmaa
