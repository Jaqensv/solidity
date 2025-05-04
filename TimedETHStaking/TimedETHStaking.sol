// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract StakingPool {
    // The pool ables to reward the users
    uint256 public pool;
    uint256 public rewardPerMinuteMultiplier;
    uint256 private constant scale = 100;
    address private owner;
    mapping(address => uint256) private userStake;
    mapping(address => uint256) private userInitialStakeTime;

    event Staked(address indexed user, uint256 indexed initialStakeTime, uint256 indexed value);
    event RewardMultiplierChanged(uint256 indexed rewardMultiplier);
    event PoolModified(address indexed from, uint256 indexed value);
    event Unstaked(address indexed user, uint256 indexed totalValue);

    constructor(uint256 _rewardMultiplier) payable {
        owner = msg.sender;
        require(msg.value > 0, "Pool deposit too low");
        pool = msg.value;
        rewardPerMinuteMultiplier = _rewardMultiplier;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function getMyStake() external view returns (uint256) {
        return userStake[msg.sender];
    }

    function getMyStakeTime() external view returns (uint256) {
        return userInitialStakeTime[msg.sender];
    }

    // A pool contributor can be any external user
    function poolDeposit() external payable {
        require(msg.value > 0, "Pool deposit too low");
        pool += msg.value;
        emit PoolModified(msg.sender, msg.value);
    }

    function rewardMultiplierModifier(uint256 _newRewardMultiplier) external onlyOwner() {
        require(_newRewardMultiplier > 0, "Reward multiplier too low");
        require(_newRewardMultiplier <= 10, "Reward multiplier to high");
        rewardPerMinuteMultiplier = _newRewardMultiplier;
        emit RewardMultiplierChanged(_newRewardMultiplier);
    }

    // Reward calculation: value * (((timestamp - stakingTime) * rewardPerMinuteMultiplier) / scale);
    function _rewardCalculation(uint256 a, uint256 b, uint256 c, uint256 d, uint256 e) public pure returns (uint256) {
        return a * (((b - c) * d) / e);
    }

    function getPendingReward() external view returns (uint256) {
        require(userStake[msg.sender] > 0, "Stake is empty");
        return _rewardCalculation(userStake[msg.sender], block.timestamp, userInitialStakeTime[msg.sender], rewardPerMinuteMultiplier, scale);
    }

    function stake() external payable {
        require(msg.value > 0, "Stake deposit too low");
        require(userStake[msg.sender] == 0, "Stake already exists");
    
        userStake[msg.sender] = msg.value;
        userInitialStakeTime[msg.sender] = block.timestamp;
    
        emit Staked(msg.sender, block.timestamp, msg.value);
    }

    function unstake() external {
        require(userStake[msg.sender] > 0, "No stake registered");
        require(block.timestamp >= userInitialStakeTime[msg.sender] + 60, "Minimum stake duration not reached");
    
        uint256 stakeAmount = userStake[msg.sender];
        uint256 startTime = userInitialStakeTime[msg.sender];
        uint256 reward = _rewardCalculation(stakeAmount, block.timestamp, startTime, rewardPerMinuteMultiplier, scale);
        uint256 totalValue = stakeAmount;

        userStake[msg.sender] = 0;
        userInitialStakeTime[msg.sender] = 0;

        if (reward <= pool) {
            pool -= reward;
            totalValue += reward;
        }

        (bool success, ) = msg.sender.call{ value: totalValue }("");
        require(success, "Transfer failed");

        emit Unstaked(msg.sender, totalValue);
    }
}
