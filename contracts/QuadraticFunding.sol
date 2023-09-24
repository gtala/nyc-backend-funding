// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract QuadraticFunding {

    //TODO: Use OpenZeppelin Ownable
    address owner;

    //Projects ended, apply quadratic funding on matching amount
      //Retrieve from 1inch or Compound for payment
      //Replace in 1inch or Compoud for staking the stake
    //3 month period - Podium Round, perform the same round
      //Straight vote; allocates proportion of votes percentage-based
    //Finally, withdraw staked stake in proportion to voters

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only owner can call this."
        );
        _;
    }

    modifier onlyContributor() {
        require(
            (contributorFlags[msg.sender] & CONTRIBUTOR_WHITELIST) != 0x0,
            "Only contributor can call this."
        );
        _;
    }

    enum StakingPlatform { OneInch, Compound }

    struct Round {
        uint256 endProjectApplicationDate;
        uint256 startRoundDate;
        uint256 endRoundDate;
        uint256 matchAmount;
        StakingPlatform platform;
    }

    struct Project {
        address payable owner;
        string name;
        uint256 matchedQFFunds;
        bool active;
    }
    
    //Project array index mapped to nextContributionID index mapped to contributions  
    mapping(uint256 => mapping(uint256 => Contribution)) contributions;
    uint256 nextContributionID;

    struct Contribution {
        address contributor;
        uint256 amount;
    }

    mapping(address => uint128) public contributorFlags;
    uint128 internal constant CONTRIBUTOR_WHITELIST = 0x1;
    uint128 internal constant CONTRIBUTOR_CONTRIBUTED = 0x2;

    Round public currentRound;
    Project[] projects;

    function createRound(uint256 _endProjectApplicationDate, uint256 _startRoundDate, uint256 _endRoundDate, StakingPlatform _platform) external payable onlyOwner {
        require(block.timestamp > currentRound.endRoundDate, "QuadraticFunding: Current round must end for new one to begin.");
        currentRound = Round(_endProjectApplicationDate, _startRoundDate, _endRoundDate, msg.value, _platform);
        //TODO: Send to 1inch or Compound for staking
    }

    /**
     * Note: We assume the sign of a bad round is just based on endRoundDate
     */
    function deleteRound() external onlyOwner {
        require(block.timestamp > currentRound.endRoundDate, "QuadraticFunding: Current round cannot be removed.");
        currentRound.endRoundDate = uint256(0);
        payable(msg.sender).transfer(address(this).balance);
    }

    function createProject(string memory _name) external {
        require(block.timestamp < currentRound.endProjectApplicationDate, "QuadraticFunding: Project application time must be active");
        projects.push(Project(payable(msg.sender), _name, 0, true));
    }

    function whitelistContributor(address contributor) external onlyOwner {
        contributorFlags[contributor] |= CONTRIBUTOR_WHITELIST;
    }

    function revokeWhitelistContributor(address contributor) external onlyOwner {
        contributorFlags[contributor] &= ~(CONTRIBUTOR_WHITELIST);
    }

    function contribute(uint256 projectIndex) external payable onlyContributor {
        require(block.timestamp > currentRound.startRoundDate, "QuadraticFunding: Round must be active");
        require(block.timestamp < currentRound.endRoundDate, "QuadraticFunding: Round cannot be expired");

        contributions[projectIndex][nextContributionID++] = Contribution(msg.sender, msg.value);
    }

    

}
