# Bug Bounty

> Smart contract vulnerability rewards platform

Bug Bounty is a decentralized platform that incentivizes the discovery and responsible disclosure of smart contract vulnerabilities. Projects post bounties, security researchers submit findings, and payments are held in escrow until vulnerabilities are confirmed and fixed.

## On-Chain Proof (Deployed & Verified)

### Base Sepolia (OP Stack)

| Contract | Address | Tx Hash |
|----------|---------|--------|
| **SeverityCalculator** | [`0x1125...Bd7E`](https://sepolia.basescan.org/address/0x11256385967A24b214273ec43e6D0e553f24Bd7E) | [`0x6707...d6d3`](https://sepolia.basescan.org/tx/0x6707925403e8e99c76b47f933f236d60dbaf5051c640c052e60606d1491ad6d3) |
| **BugBountyPlatform** | [`0x83D0...c0b0`](https://sepolia.basescan.org/address/0x83D00c5a90dfD87B37677D734F2eFe47EadDc0b0) | [`0x9655...1150`](https://sepolia.basescan.org/tx/0x96559ca95a5a44b0631679f1d0e326430ab1d0bf289dcbc31f713be74f631150) |

**Deployer**: [`0x7F75...C739`](https://sepolia.basescan.org/address/0x7F75bfAfeD5c96584774c7F2Bc33F3bF887BC739) | **Network**: Base Sepolia
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
