// SPDX-License-Identifier : MIT
pragma solidity ^0.8.24;

contract Vesting {

    mapping(address => uint256) private userBalances;
    mapping(address => uint256) private userDepositTime;
    uint256 public lockTime;
    address private owner;

    event Locked(address indexed beneficiary, uint256 indexed userDepositTime, uint256 indexed value);
    event Released(address indexed beneficiary, uint256 indexed value);

    constructor(uint256 _lockTime) {
        owner = msg.sender;
        lockTime = _lockTime;
    } 

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function getMyBalance() external view returns (uint256) {
        return userBalances[msg.sender];
    }

    function getMyDepositTime() external view returns (uint256) {
        return userDepositTime[msg.sender];
    }

    function lock(address _beneficiary) external payable onlyOwner() {
        require(userBalances[_beneficiary] == 0 && msg.value > 0);
        userBalances[_beneficiary] = msg.value;
        userDepositTime[_beneficiary] = block.timestamp;
        emit Locked(_beneficiary, userDepositTime[_beneficiary], msg.value);
    }

    function release() external {
        require(userBalances[msg.sender] > 0 && userDepositTime[msg.sender] + lockTime <= block.timestamp);
        uint256 releaseValue = userBalances[msg.sender];
        userBalances[msg.sender] = 0;
        userDepositTime[msg.sender] = 0;
        (bool success, ) = address(msg.sender).call{value: releaseValue}("");
        require(success, "Call failed");
        emit Released(msg.sender, releaseValue);
    }

    function getReleaseTime() external view returns(uint256) {
        require(userBalances[msg.sender] > 0, "No deposit found");
        uint256 unlockTime = userDepositTime[msg.sender] + lockTime;
        if (block.timestamp >= unlockTime) {
            return 0;
        }
        return unlockTime - block.timestamp;
    }
}