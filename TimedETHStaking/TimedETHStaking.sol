// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract StakingPool {
    uint256 public rewardPerMinuteMultiplier;
    uint256 public scale = 100;
    address public owner;
    mapping(address => uint256) public userStake;
    mapping(address => uint256) public userInitialStakeTime;
    // The pool ables to reward the users
    uint256 public pool;

    event Staked(address indexed user, uint256 indexed initialStakeTime, uint256 indexed value);
    event RewardMultiplierChanged(uint256 indexed rewardMultiplier);
    event PoolModified(address indexed from, uint256 indexed value);
    event Unstaked(address indexed user, uint256 indexed totalValue);

    constructor(uint256 _rewardMultiplier) payable {
        owner = msg.sender;
        require(msg.value > 0);
        pool = msg.value;
        rewardPerMinuteMultiplier = _rewardMultiplier;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // A pool contributor can be any external user
    function poolDeposit() external payable {
        require(msg.value > 0);
        pool += msg.value;
        emit PoolModified(msg.sender, msg.value);
    }

    function rewardMultiplierModifier(uint256 _newRewardMultiplier) external onlyOwner() {
        require(_newRewardMultiplier > 0 && _newRewardMultiplier <= 10);
        rewardPerMinuteMultiplier = _newRewardMultiplier;
        emit RewardMultiplierChanged(_newRewardMultiplier);
    }

    // Reward calculation: value * (((timestamp - stakingTime) * rewardPerMinuteMultiplier) / scale);
    function _rewardCalculation(uint256 a, uint256 b, uint256 c, uint256 d, uint256 e) private pure returns (uint256) {
        return a * (((b - c) * d) / e);
    }

    // Address as an argument suggested in the subject seems to be useless here. Using msg.sender might be correct.
    function getPendingReward() external view returns (uint256) {
        require(userStake[msg.sender] > 0);
        return _rewardCalculation(userStake[msg.sender], block.timestamp, userInitialStakeTime[msg.sender], rewardPerMinuteMultiplier, scale);
    }

    function _canPoolAffordReward(address user) private view returns (bool) {
        uint256 expectedReward = _rewardCalculation(userStake[user], block.timestamp, userInitialStakeTime[user], rewardPerMinuteMultiplier, scale);
        if (expectedReward <= pool) {
            return true;
        }
        return false;
    }

    function stake() external payable {
        require(msg.value > 0 && userStake[msg.sender] == 0);
        userStake[msg.sender] = msg.value;
        userInitialStakeTime[msg.sender] = block.timestamp;
        emit Staked(msg.sender, block.timestamp, msg.value);
    }

    function unstake() external {
        require(userStake[msg.sender] > 0);
        uint256 totalValue = userStake[msg.sender];
        userStake[msg.sender] = 0;
        if (_canPoolAffordReward(msg.sender)) {

            uint256 reward = _rewardCalculation(userStake[msg.sender], block.timestamp, userInitialStakeTime[msg.sender], rewardPerMinuteMultiplier, scale);
            pool -= reward;
            totalValue += reward;
        }
        (bool success, ) = address(msg.sender).call{ value: totalValue }("");
        require(success, "Transfer failed");
        emit Unstaked(msg.sender,totalValue);
    }
}
