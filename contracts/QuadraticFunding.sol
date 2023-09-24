// SPDX-License-Identifier: UNLICENSED
import "./Babylonian.sol";
import "./IWETH9.sol";
import "./Comet.sol";
import "./MockStaker.sol";

pragma solidity ^0.8.0;

contract QuadraticFunding {

    //TODO: Use OpenZeppelin Ownable
    address owner;

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

    enum StakingPlatform { OneInch, Compound, MockStaker }

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
    mapping(address => uint) projectIndexMap;

    address public COMPOUND_COMET_ADDRESS;
    address public ONEINCH_ADDRESS;
    address public WETH_ADDRESS;
    address public MOCKSTAKER_ADDRESS;

    //Podium Round
    struct PodiumRound {
        uint256 endRoundDate;
    }

    //Project index => 
    //Replace string[20] with mapping(uint => string) if needed, then make mapping for
    mapping(uint256 => mapping(uint => string)) public projectIPFSHashes;
    //project index => nextIPFSHashID
    mapping(uint256 => uint256) public projectNextIPFSHashIDs;
    
    PodiumRound currentPodiumRound;
    //Mapped Project indexes to votes
    mapping(uint => uint) public podiumVotes;

    constructor(address _compoundCometAddress, address _oneInchAddress, address _wethAddress) {
        COMPOUND_COMET_ADDRESS = _compoundCometAddress;
        ONEINCH_ADDRESS = _oneInchAddress;
        WETH_ADDRESS = _wethAddress;
        owner = msg.sender;
    }

    //Just for testing
    function setMockStaker(address maddr) public {
        MOCKSTAKER_ADDRESS = maddr;
    }

    function createRound(uint256 _endProjectApplicationDate, uint256 _startRoundDate, uint256 _endRoundDate, StakingPlatform _platform) external payable onlyOwner {
//        require(block.timestamp > currentRound.endRoundDate, "QuadraticFunding: Current round must end for new one to begin.");
        currentRound = Round(_endProjectApplicationDate, _startRoundDate, _endRoundDate, msg.value, _platform);
        //TODO: Send to 1inch or Compound for staking
        if(_platform == StakingPlatform.OneInch) {
        
        } else if(_platform == StakingPlatform.Compound) {            
            IWETH9 weth = IWETH9(WETH_ADDRESS);
            weth.deposit{value: msg.value}();
            weth.approve(COMPOUND_COMET_ADDRESS, msg.value);
            Comet c = Comet(COMPOUND_COMET_ADDRESS);
            c.supply(WETH_ADDRESS, msg.value);
        } else if(_platform == StakingPlatform.MockStaker) {
            MockStaker ms = MockStaker(MOCKSTAKER_ADDRESS);
            ms.stake{value: msg.value}();
        }
    }

    /**
     * Note: We assume the sign of a bad round is just based on endRoundDate
     */
    function deleteRound() external onlyOwner {
        require(block.timestamp > currentRound.endRoundDate, "QuadraticFunding: Current round cannot be removed.");
        currentRound.endRoundDate = uint256(0);
        payable(msg.sender).transfer(address(this).balance);
    }

    function createProject(string memory _name) external returns (uint256 projectIndex) {
//        require(block.timestamp < currentRound.endProjectApplicationDate, "QuadraticFunding: Project application time must be active");
        projects.push(Project(payable(msg.sender), _name, 0, true));
        projectIndex = projects.length - 1;
        projectIndexMap[msg.sender] = projectIndex;
    }

    function whitelistContributor(address contributor) external onlyOwner {
        contributorFlags[contributor] |= CONTRIBUTOR_WHITELIST;
    }

    function revokeWhitelistContributor(address contributor) external onlyOwner {
        contributorFlags[contributor] &= ~(CONTRIBUTOR_WHITELIST);
    }

    function contribute(uint256 projectIndex) external payable onlyContributor {
//        require(block.timestamp > currentRound.startRoundDate, "QuadraticFunding: Round must be active");
//        require(block.timestamp < currentRound.endRoundDate, "QuadraticFunding: Round cannot be expired");
        require((contributorFlags[msg.sender] & CONTRIBUTOR_CONTRIBUTED) != 0, "QuadraticFunding: Contributer already submitted contribution");

        contributions[projectIndex][nextContributionID++] = Contribution(msg.sender, msg.value);
        projects[projectIndex].owner.transfer(msg.value);
        contributorFlags[msg.sender] |= CONTRIBUTOR_CONTRIBUTED;
    }

    // After this function is called, we should have extra kept in the staking contract
    function quadraticFunding() external {
//        require(block.timestamp > currentRound.endRoundDate, "QuadraticFunding: Round has not ended yet");
        //Need to add something here to ensure it can't be called twice, e.g. bool
        if(currentRound.platform == StakingPlatform.OneInch) {

        } else if(currentRound.platform == StakingPlatform.Compound) {
            Comet c = Comet(COMPOUND_COMET_ADDRESS);
            uint amount = currentRound.matchAmount;
            c.withdraw(WETH_ADDRESS, amount);
            IWETH9 weth = IWETH9(WETH_ADDRESS);
            weth.withdraw(amount);
        } else if(currentRound.platform == StakingPlatform.MockStaker) {
            uint amount = currentRound.matchAmount;
            MockStaker ms = MockStaker(MOCKSTAKER_ADDRESS);
            ms.withdraw(amount);
        }

        //Used as holding proportions, later transformed into funding amount
        uint[] memory proportions = new uint[](projects.length);
        uint proportionSum = 0;
        for(uint i = 0; i < projects.length; ++i) {
            proportions[i] = _quadraticFundingMath(i);
            proportionSum += proportions[i];
        }
        //Finally, calculate funding amounts and distribute
        for(uint i = 0; i < projects.length; ++i) {
            projects[i].owner.transfer((currentRound.matchAmount * proportions[i])/proportionSum);
        }
    }

    function _quadraticFundingMath(uint pidx) internal view returns (uint) {
        uint sum = 0;
        for(uint i = 0; i < nextContributionID; ++i) {
            sum += Babylonian.sqrt(contributions[pidx][i].amount);
        }
        return sum * sum;
    }

    //Create PodiumRound(done by owner)
    //uploadResults(string[] results) (get from msg.sender which we can use projectIndexMap to get the index and then associate that with the ipfsHashes)

    function createPodiumRound(uint _endRoundDate) public onlyOwner {
        currentPodiumRound = PodiumRound(_endRoundDate);
    }

    function uploadResults(string[] memory _ipfsHashes) public {
        uint projectIndex = projectIndexMap[msg.sender];
        for(uint i = 0; i < _ipfsHashes.length; ++i) {
            projectIPFSHashes[projectIndex][projectNextIPFSHashIDs[projectIndex]++] = _ipfsHashes[i];
        }
    }

    function podiumVote(uint projectIndex) public {
        ++podiumVotes[projectIndex];
    }

    //distributePodiumPrizes() 0. Pull the total amount of staked ETH from platform, withdraw all from platform, withdraw all from WETH. 1. Calculate all podiumVotes for each project, 2. Calculate the sum of podiumVotes, 3. Calculate each prize winnings by multiplying votes * total prize winnings / sum of podium Votes and distribute that amount
    function distributePodiumPrizes() public {
        uint128 amount;
        if(currentRound.platform == StakingPlatform.OneInch) {
        
        } else if(currentRound.platform == StakingPlatform.Compound) {
            Comet c = Comet(COMPOUND_COMET_ADDRESS);
            amount = c.collateralBalanceOf(address(this), WETH_ADDRESS);
            Comet(COMPOUND_COMET_ADDRESS).withdraw(WETH_ADDRESS, amount);
        } else if(currentRound.platform == StakingPlatform.MockStaker) {
            MockStaker ms = MockStaker(MOCKSTAKER_ADDRESS);
            amount = uint128(ms.withdrawAll());
        }
        uint sumPodiumVotes = 0;
        for(uint i = 0; i < projects.length; ++i) {
            sumPodiumVotes += podiumVotes[i];
        }

        for(uint i = 0; i < projects.length; ++i) {
            projects[i].owner.transfer((podiumVotes[i] * amount)/sumPodiumVotes);
        }
    }

    //Projects ended, apply quadratic funding on matching amount
      //Retrieve from 1inch or Compound for payment
      //Replace in 1inch or Compound for staking the stake
    //3 month period - Podium Round, perform the same round
      //Straight vote; allocates proportion of votes percentage-based
    //Finally, withdraw staked stake in proportion to voters

}
