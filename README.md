# Bug Bounty

> Smart contract vulnerability rewards platform

Bug Bounty is a decentralized platform that incentivizes the discovery and responsible disclosure of smart contract vulnerabilities. Projects post bounties, security researchers submit findings, and payments are held in escrow until vulnerabilities are confirmed and fixed.

## On-Chain Proof

| Contract | Address |
|----------|---------|
| BugBountyRegistry | `TBD` |
| BountyEscrow | `TBD` |
| SubmissionManager | `TBD` |
| SeverityClassifier | `TBD` |

Network: Ethereum Mainnet

## How It Works

1. **Post Bounty**: A project registers their smart contract and deposits a bounty fund into the BountyEscrow. They specify the scope, excluded contracts, and bounty tiers by severity.

2. **Submit Vulnerability**: Security researchers submit vulnerability reports with detailed descriptions, proof-of-concept code, and severity assessments. Submissions are encrypted and time-stamped.

3. **Triage**: The project's security team reviews submissions within a defined SLA. Valid vulnerabilities are confirmed, and severity is classified (critical, high, medium, low).

4. **Resolution**: The project fixes the vulnerability and provides a fix verification hash. The fix is independently validated by the platform's triage team.

5. **Payout**: Upon confirmation, the BountyEscrow releases the bounty payment to the researcher. Reputation points are awarded based on severity and quality of the finding.

## Smart Contracts

```
contracts/
├── BugBountyRegistry.sol          # Project and bounty registration
├── BountyEscrow.sol               # Escrow for bounty funds
├── SubmissionManager.sol          # Vulnerability submission and review
├── SeverityClassifier.sol         # Automated severity classification
├── ReputationManager.sol          # Researcher reputation tracking
├── interfaces/
│   ├── IBounty.sol
│   └── ISubmission.sol
└── libraries/
    ├── EscrowLib.sol
    └── SeverityLib.sol
```

### Key Features

- **Escrow Protection**: Bounty funds are locked in escrow—researchers are guaranteed payment for valid findings.
- **Tiered Rewards**: Bounty amounts scale with vulnerability severity (critical = highest reward).
- **Responsible Disclosure**: Structured process ensures vulnerabilities are fixed before public disclosure.
- **Researcher Reputation**: On-chain reputation tracks researcher credibility and contribution history.
- **SLA Enforcement**: Projects face penalties for delayed response to valid submissions.

## Setup

### Prerequisites

- Node.js >= 18
- Foundry
- Wallet with testnet ETH

### Installation

```bash
git clone https://github.com/Souravjoy7/bug-bounty.git
cd bug-bounty
npm install
```

### Compile

```bash
forge build
```

### Test

```bash
forge test
```

### Deploy

```bash
forge script script/Deploy.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
```

### Environment Variables

```
RPC_URL=<your-rpc-url>
PRIVATE_KEY=<your-deployer-key>
ETHERSCAN_API_KEY=<your-etherscan-key>
MIN_BOUNTY_USD=1000
TRIAGE_PERIOD_DAYS=14
```

## License

MIT License. See [LICENSE](LICENSE) for details.
