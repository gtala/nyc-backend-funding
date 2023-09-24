# Podium

## Documentation

### Setup
Deploy the `QuadraticFunding.sol` contract with the addresses of Compound's Comet contract, the 1Inch Contract (0x0 is fine here for now), and the WETH9 contract, all as deployed on the relevant network.

### Initial Round

1. `function createRound(uint256 _endProjectApplicationDate, uint256 _startRoundDate, uint256 _endRoundDate, StakingPlatform _platform) external payable onlyOwner;`

Supply the relevant timestamps for the initial round of funding for Quadratic Funding, as well as a Staking Platform (StakingPlatform.Compound is recommended). **Important**: Send the amount of ETH along with this transaction in order to supply the matching funds for the pool and for quadratic funding. The funds will be staked in the specified platform.

2. `function createProject(string memory _name) external returns (uint256 projectIndex);`
Provide a name for a project intended for fundraising during the initial Quadratic Funding round. Returns that `projectIndex` at which the project is stored.

3. `function whitelistContributor(address contributor) external onlyOwner;`
Calling this function is important for ensuring that a contributor is allowed to vote (used as a counter to Sybil)

4. `function contribute(uint256 projectIndex) external payable onlyContributor;`
Calling this function with ETH will donate that amount towards the project at `projectIndex`.

5. `function quadraticFunding() external;`
Once all contributors have participating in donating in their desired projects via `contribute` and the timeframe is up for the initial round, this function is called to reward users via quadratic funding. Staked funds equivalent to the matching amount are withdrawn, but the current running yield is kept for further yield until the Podium round.

### Podium Round

## Building, Testing, Deploying
```
npx hardhat compile
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat run scripts/deploy.ts
```
