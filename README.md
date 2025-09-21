# ProgramVote

A decentralized voting system smart contract for academic program approval built on the Stacks blockchain using Clarity.

## Description

ProgramVote is a smart contract that enables secure, transparent voting on academic program proposals. The system features authorized voter management, time-bound voting periods, and automatic program approval based on majority consensus. Only pre-approved voters can participate in the voting process, ensuring controlled and legitimate decision-making for academic institutions.

## Features

- **Authorized Voter Management**: Contract owner can add and remove authorized voters
- **Program Proposal Submission**: Anyone can submit academic program proposals with custom voting periods
- **Secure Voting System**: Prevents double voting and enforces voting deadlines
- **Automatic Finalization**: Programs are automatically approved or rejected based on majority vote
- **Transparent Results**: All voting data is publicly accessible on the blockchain
- **Time-Bound Voting**: Each proposal has a configurable voting period measured in blocks
- **Owner Controls**: Contract deployer maintains administrative privileges

## Technical Specifications

- **Blockchain**: Stacks
- **Language**: Clarity v2
- **Epoch**: 2.5
- **Contract Name**: ProgramVote
- **Version**: 1.0.0

## Installation

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks smart contract development tool
- [Node.js](https://nodejs.org/) (v16 or higher)
- [Git](https://git-scm.com/)

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd ProgramVote
```

2. Navigate to the contract directory:
```bash
cd ProgramVote_contract
```

3. Install dependencies:
```bash
npm install
```

4. Check contract syntax:
```bash
clarinet check
```

## Usage Examples

### Deploy and Initialize Contract

```clarity
;; Deploy the contract (automatically sets deployer as contract owner)
;; Call initialize to set up the contract
(contract-call? .ProgramVote initialize)
```

### Add Authorized Voters

```clarity
;; Only contract owner can add authorized voters
(contract-call? .ProgramVote add-authorized-voter 'SP1234567890ABCDEF)
```

### Submit a Program Proposal

```clarity
;; Anyone can submit a program proposal
(contract-call? .ProgramVote submit-program
    "Computer Science Masters"
    "A comprehensive master's program in computer science focusing on AI and machine learning"
    u1000) ;; Voting period of 1000 blocks (~1 week)
```

### Vote on a Proposal

```clarity
;; Authorized voters can vote yes or no
(contract-call? .ProgramVote vote u1 true)  ;; Vote yes on program ID 1
(contract-call? .ProgramVote vote u1 false) ;; Vote no on program ID 1
```

### Finalize Voting

```clarity
;; Anyone can finalize voting after the voting period ends
(contract-call? .ProgramVote finalize-program u1)
```

## Contract Functions Documentation

### Public Functions

#### `initialize()`
Initializes the contract and adds the deployer as the first authorized voter.
- **Returns**: `(response bool uint)`

#### `add-authorized-voter(voter: principal)`
Adds a new authorized voter (owner only).
- **Parameters**: `voter` - Principal address to authorize
- **Returns**: `(response bool uint)`
- **Access**: Contract owner only

#### `remove-authorized-voter(voter: principal)`
Removes an authorized voter (owner only).
- **Parameters**: `voter` - Principal address to remove
- **Returns**: `(response bool uint)`
- **Access**: Contract owner only

#### `submit-program(title: string-ascii 100, description: string-ascii 500, voting-blocks: uint)`
Submits a new program proposal for voting.
- **Parameters**:
  - `title` - Program title (max 100 characters)
  - `description` - Program description (max 500 characters)
  - `voting-blocks` - Number of blocks for voting period
- **Returns**: `(response uint uint)` - Program ID on success

#### `vote(program-id: uint, vote-yes: bool)`
Casts a vote on a program proposal.
- **Parameters**:
  - `program-id` - ID of the program to vote on
  - `vote-yes` - true for yes vote, false for no vote
- **Returns**: `(response bool uint)`
- **Requirements**: Must be authorized voter, voting period active, haven't voted before

#### `finalize-program(program-id: uint)`
Finalizes voting for a program after voting period ends.
- **Parameters**: `program-id` - ID of the program to finalize
- **Returns**: `(response bool uint)` - true if program approved
- **Access**: Anyone can call after voting period ends

### Read-Only Functions

#### `is-authorized-voter(voter: principal)`
Checks if a principal is an authorized voter.
- **Returns**: `bool`

#### `get-program(program-id: uint)`
Retrieves complete program details.
- **Returns**: `(optional program-data)`

#### `has-voted(voter: principal, program-id: uint)`
Checks if a voter has already voted on a specific program.
- **Returns**: `bool`

#### `get-next-program-id()`
Returns the next available program ID.
- **Returns**: `uint`

#### `get-vote-results(program-id: uint)`
Gets voting results for a program.
- **Returns**: Vote counts, totals, and approval status

#### `is-voting-open(program-id: uint)`
Checks if voting is still open for a program.
- **Returns**: `(response bool uint)`

#### `get-contract-owner()`
Returns the contract owner's principal.
- **Returns**: `principal`

## Deployment Guide

### Local Development

1. Start Clarinet console:
```bash
clarinet console
```

2. Deploy and test the contract:
```clarity
(contract-call? .ProgramVote initialize)
```

### Testnet Deployment

1. Configure your testnet settings in `settings/Testnet.toml`

2. Deploy to testnet:
```bash
clarinet deploy --testnet
```

### Mainnet Deployment

1. Configure mainnet settings in `settings/Mainnet.toml`

2. Deploy to mainnet:
```bash
clarinet deploy --mainnet
```

## Testing

Run the test suite:

```bash
# Run all tests
npm test

# Run tests with coverage report
npm run test:report

# Watch for changes and run tests automatically
npm run test:watch
```

## Security Notes

### Access Controls
- Only the contract owner can manage authorized voters
- Voter authorization is required for all voting operations
- Double voting is prevented through vote tracking

### Voting Integrity
- Each voter can only vote once per program
- Votes cannot be changed once cast
- Voting periods are enforced at the block level
- Programs require majority approval (more yes than no votes)

### Data Validation
- Program titles limited to 100 ASCII characters
- Descriptions limited to 500 ASCII characters
- Voting periods must be greater than 0 blocks
- All inputs are validated before processing

### Potential Considerations
- Block time variations may affect voting period duration
- No vote delegation or proxy voting supported
- Program proposals cannot be modified after submission
- No minimum participation threshold (programs can be approved with 1 yes vote)

## Error Codes

- `u100`: Owner only operation
- `u101`: Not authorized to vote
- `u102`: Program not found
- `u103`: Already voted on this program
- `u104`: Voting period has ended
- `u105`: Program already exists
- `u106`: Invalid voting period

## License

This project is licensed under the ISC License.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## Support

For questions, issues, or contributions, please open an issue in the repository or contact the development team.