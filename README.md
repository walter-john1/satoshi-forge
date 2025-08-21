# Satoshi Forge - BTC Yield Fusion Protocol

[![Clarity](https://img.shields.io/badge/Clarity-v3-blue.svg)](https://clarity-lang.org/)
[![Stacks](https://img.shields.io/badge/Stacks-Blockchain-orange.svg)](https://www.stacks.co/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> A modular, multi-strategy BTC yield optimizer enabling decentralized allocation of Bitcoin-based assets across whitelisted protocols with APY-driven logic.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [API Reference](#api-reference)
- [Testing](#testing)
- [Security](#security)
- [Contributing](#contributing)
- [License](#license)

## 🔍 Overview

Satoshi Forge is a decentralized protocol built on Clarity that facilitates secure deposits of BTC-pegged tokens (via SIP-010), with automated distribution of funds into multiple whitelisted DeFi strategies. Users earn compound yield based on protocol APYs and allocations, with a full-featured reward system, deposit/withdrawal lifecycle, platform-level fee management, and emergency controls.

### Key Benefits

- **Multi-Strategy Yield**: Automatically distribute funds across multiple DeFi protocols
- **Compound Rewards**: Earn yield based on weighted APY calculations
- **Security First**: Comprehensive access controls and emergency shutdown mechanisms
- **Token Agnostic**: Support for any SIP-010 compliant Bitcoin-pegged tokens
- **Transparent Fees**: Clear fee structure with admin-controlled parameters

## ✨ Features

### Core Functionality

- **Token Deposits & Withdrawals**: Secure handling of SIP-010 tokens
- **Multi-Protocol Allocation**: Distribute funds across whitelisted yield strategies
- **Dynamic APY Calculation**: Real-time yield calculations based on protocol performance
- **Reward Management**: Automated reward distribution and claiming
- **Emergency Controls**: Circuit breakers for protocol safety

### Admin Features

- **Protocol Management**: Add, update, and manage yield protocols
- **Token Whitelisting**: Control which tokens are accepted
- **Fee Configuration**: Adjustable platform fees
- **Strategy Allocation**: Configure fund distribution across protocols
- **Emergency Shutdown**: Global pause functionality

### User Features

- **Deposit Management**: Flexible deposit amounts with min/max limits
- **Reward Claiming**: On-demand reward claiming
- **Portfolio Tracking**: View deposits and pending rewards
- **Multi-Token Support**: Interact with various BTC-pegged tokens

## 🏗️ Architecture

### Smart Contract Structure

```
satoshi-forge.clar
├── Constants & Error Codes
├── Data Variables (TVL, Fees, Limits)
├── Storage Maps
│   ├── user-deposits
│   ├── user-rewards
│   ├── protocols
│   ├── strategy-allocations
│   └── whitelisted-tokens
├── SIP-010 Token Trait
├── Core Functions
│   ├── Protocol Management
│   ├── Token Management
│   ├── Deposit/Withdrawal
│   ├── Reward System
│   └── Admin Controls
└── Helper Functions
```

### Data Flow

1. **Token Whitelisting**: Admin whitelists SIP-010 tokens
2. **Protocol Registration**: Admin adds yield protocols with APY rates
3. **User Deposits**: Users deposit whitelisted tokens
4. **Fund Allocation**: Automated distribution based on strategy allocations
5. **Yield Calculation**: Continuous APY-based reward accumulation
6. **Reward Claims**: Users claim accumulated rewards
7. **Withdrawals**: Users withdraw principal and unclaimed rewards

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) v2.0+
- [Node.js](https://nodejs.org/) v18+
- [Git](https://git-scm.com/)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/walter-john1/satoshi-forge.git
   cd satoshi-forge
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Verify installation**

   ```bash
   clarinet check
   ```

### Quick Start

1. **Run tests**

   ```bash
   npm test
   ```

2. **Start development environment**

   ```bash
   clarinet integrate
   ```

3. **Deploy to testnet**

   ```bash
   clarinet publish --testnet
   ```

## 💻 Usage

### For Users

#### Depositing Tokens

```clarity
;; Deposit 1000000 satoshis of a whitelisted BTC token
(contract-call? .satoshi-forge deposit .my-btc-token u1000000)
```

#### Claiming Rewards

```clarity
;; Claim accumulated rewards
(contract-call? .satoshi-forge claim-rewards .my-btc-token)
```

#### Withdrawing Funds

```clarity
;; Withdraw 500000 satoshis
(contract-call? .satoshi-forge withdraw .my-btc-token u500000)
```

### For Administrators

#### Adding a Protocol

```clarity
;; Add a new yield protocol with 5% APY
(contract-call? .satoshi-forge add-protocol 
  u1 
  "Lightning Pool" 
  u500)  ;; 5% in basis points
```

#### Whitelisting Tokens

```clarity
;; Whitelist a new BTC-pegged token
(contract-call? .satoshi-forge whitelist-token .new-btc-token)
```

#### Setting Platform Fees

```clarity
;; Set platform fee to 1% (100 basis points)
(contract-call? .satoshi-forge set-platform-fee u100)
```

## 📖 API Reference

### Public Functions

#### User Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `deposit` | `token-trait`, `amount` | Deposit tokens into the protocol |
| `withdraw` | `token-trait`, `amount` | Withdraw tokens from the protocol |
| `claim-rewards` | `token-trait` | Claim accumulated rewards |

#### Admin Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `add-protocol` | `protocol-id`, `name`, `initial-apy` | Add a new yield protocol |
| `update-protocol-status` | `protocol-id`, `active` | Enable/disable a protocol |
| `update-protocol-apy` | `protocol-id`, `new-apy` | Update protocol APY |
| `whitelist-token` | `token` | Whitelist a SIP-010 token |
| `set-platform-fee` | `new-fee` | Set platform fee rate |
| `set-emergency-shutdown` | `shutdown` | Enable/disable emergency mode |

### Read-Only Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `get-protocol` | `protocol-id` | Get protocol details |
| `get-user-deposit` | `user` | Get user deposit information |
| `get-total-tvl` | - | Get total value locked |
| `is-whitelisted` | `token` | Check if token is whitelisted |

### Error Codes

| Code | Error | Description |
|------|-------|-------------|
| `u1000` | `ERR-NOT-AUTHORIZED` | Caller not authorized |
| `u1001` | `ERR-INVALID-AMOUNT` | Invalid amount provided |
| `u1002` | `ERR-INSUFFICIENT-BALANCE` | Insufficient balance |
| `u1003` | `ERR-PROTOCOL-NOT-WHITELISTED` | Protocol not whitelisted |
| `u1004` | `ERR-STRATEGY-DISABLED` | Strategy is disabled |
| `u1005` | `ERR-MAX-DEPOSIT-REACHED` | Maximum deposit limit reached |
| `u1006` | `ERR-MIN-DEPOSIT-NOT-MET` | Minimum deposit not met |
| `u1007` | `ERR-INVALID-PROTOCOL-ID` | Invalid protocol ID |
| `u1008` | `ERR-PROTOCOL-EXISTS` | Protocol already exists |
| `u1009` | `ERR-INVALID-APY` | Invalid APY value |
| `u1010` | `ERR-INVALID-NAME` | Invalid name provided |
| `u1011` | `ERR-INVALID-TOKEN` | Invalid token |
| `u1012` | `ERR-TOKEN-NOT-WHITELISTED` | Token not whitelisted |

## 🧪 Testing

The project uses Vitest with Clarinet SDK for comprehensive testing.

### Running Tests

```bash
# Run all tests
npm test

# Run tests with coverage
npm run test:report

# Watch mode for development
npm run test:watch
```

### Test Structure

```
tests/
└── satoshi-forge.test.ts    # Main contract tests
```

### Writing Tests

Example test structure:

```typescript
import { describe, expect, it } from "vitest";

describe("Satoshi Forge Protocol", () => {
  it("should allow deposits", () => {
    // Test deposit functionality
  });

  it("should calculate rewards correctly", () => {
    // Test reward calculations
  });

  it("should handle withdrawals", () => {
    // Test withdrawal functionality
  });
});
```

## 🔐 Security

### Security Features

- **Access Control**: Owner-only functions for critical operations
- **Input Validation**: Comprehensive parameter validation
- **Emergency Shutdown**: Global pause functionality
- **Balance Checks**: Prevents overdrafts and invalid transfers
- **Protocol Limits**: Configurable min/max deposit limits

### Best Practices

1. **Always validate inputs** before processing
2. **Use assertions** for critical conditions
3. **Implement proper access controls** for admin functions
4. **Test edge cases** thoroughly
5. **Monitor protocol health** regularly

### Audit Recommendations

- Regular security audits by qualified firms
- Formal verification of critical functions
- Bug bounty programs for community testing
- Gradual rollout with monitoring

## 🤝 Contributing

We welcome contributions to Satoshi Forge! Please follow these guidelines:

### Development Process

1. **Fork** the repository
2. **Create** a feature branch
3. **Write** tests for new functionality
4. **Ensure** all tests pass
5. **Submit** a pull request

### Code Standards

- Follow Clarity best practices
- Include comprehensive tests
- Document all public functions
- Use meaningful variable names
- Add inline comments for complex logic

### Pull Request Process

1. Update documentation if needed
2. Add tests for new features
3. Ensure CI passes
4. Request review from maintainers

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Stacks Foundation** for the blockchain infrastructure
- **Clarity Language** for secure smart contract development
- **Community Contributors** for feedback and improvements
