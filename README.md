# FrontEnd Repository
https://github.com/gtala/nyc-founding-frontend

# Podium
Using Polygon and Safe, Compound, Next.ID, and IPFS, to help fund and incentivize public goods projects with verifiable results reported via “Proof of Direct Impact Using Metadata” (“PODIUM”), and establishing a link between public goods projects, crowdfunding to fund those projects, and impact focused retrospective funding.

## Inspiration
The inspiration for Podium emerged from the growing need to address the proof of impact after donations and grants are given to public goods projects and to incentivize funding recipients to follow through and report back on the progress with their public good projects, and then be eligible for retrospective funding
 
**The Problem**

Public goods funding faces the following hurdles:
1. Donors find it hard to see where their donations are really making an impact: **results feedback is missing**.
2. **Lack of retrospective funding**: Public good projects find it difficult to access a seamless path to retrospective funding
With Podium, anyone anywhere can generate proof of their direct impact and share with the community of vested stakeholders. 

## What it does
**Our Solution:** A dApp that allows users to:
1. Podium is a dApp that allows users to :
2. Easy login with Polygon account abstraction and Safe wallet. 
3. Next.ID to establish credentials with credibility and reduce sybill attacks
4. Funding pools staked on 1-Inch and Compound.  
5. After payout from the quadratic funding,, the yield is incentive to report back for the PODIUM round
6. PODIUM captures on-chain meta data of geographic location, time and date stamp, and Next ID attestation. 

## Documentation

### Setup

1. `constructor(address _compoundCometAddress, address _oneInchAddress, address _wethAddress)`
* Deploy the `QuadraticFunding.sol` contract with the addresses of Compound's Comet contract, the 1Inch Contract (0x0 is fine here for now), and the WETH9 contract, all as deployed on the relevant network.

### Initial Round

1. `function createRound(uint256 _endProjectApplicationDate, uint256 _startRoundDate, uint256 _endRoundDate, StakingPlatform _platform) external payable onlyOwner;`
* Supply the relevant timestamps for the initial round of funding for Quadratic Funding, as well as a Staking Platform (StakingPlatform.Compound is recommended). **Important**: Send the amount of ETH along with this transaction in order to supply the matching funds for the pool and for quadratic funding. The funds will be staked in the specified platform.

2. `function createProject(string memory _name) external returns (uint256 projectIndex);`
* Provide a name for a project intended for fundraising during the initial Quadratic Funding round. Returns that `projectIndex` at which the project is stored.

3. `function whitelistContributor(address contributor) external onlyOwner;`
* Calling this function is important for ensuring that a contributor is allowed to vote (used as a counter to Sybil)

4. `function contribute(uint256 projectIndex) external payable onlyContributor;`
* Calling this function with ETH will donate that amount towards the project at `projectIndex`.

5. `function quadraticFunding() external;`
* Once all contributors have participating in donating in their desired projects via `contribute` and the timeframe is up for the initial round, this function is called to reward users via quadratic funding. Staked funds equivalent to the matching amount are withdrawn, but the current running yield is kept for further yield until the Podium round.

### Podium Round

1. `function createPodiumRound(uint _endRoundDate) public onlyOwner;`
* Create the podium round, supplying a timestamp for the end. This must take place after the initial round has concluded (e.g. after calling `quadraticFunding()`).

2. `function uploadResults(string[] memory _ipfsHashes) public;`
* Now that the Podium round has begun, projects can begin to upload their results via an array of IPFS hashes. Each IPFS hash will be recorded within the smart contract and mapped to the project, assuming the `msg.sender` is a project.

3. `function podiumVote(uint projectIndex) public;`
* Contributors can now vote on a project once by passing the index of the project they would like to vote for.

4. `function distributePodiumPrizes() public;`
* After the voting has concluded with the end of the Podium round, calling this function will withdraw all staked assets and will distribute them proportional to the number of votes each project received.

## Building, Testing, Deploying
```
npx hardhat compile
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat run scripts/deploy.ts
```
