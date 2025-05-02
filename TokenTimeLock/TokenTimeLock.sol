// SPDX-License-Identifier : MIT
pragma solidity ^0.8.24;

contract Vesting {

    mapping(address => uint) public userBalances;
    mapping(address => uint) public userDepositTime;
    uint public lockTime;
    address public owner;

    event Locked(address indexed beneficiary, uint indexed userDepositTime, uint indexed value);
    event Released(address indexed beneficiary, uint indexed value);

    constructor(uint _lockTime) {
        owner = msg.sender;
        lockTime = _lockTime;
    } 

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function lock(address _beneficiary) external payable onlyOwner() {
        require(userBalances[_beneficiary] == 0 && msg.value > 0);
        userBalances[_beneficiary] = msg.value;
        userDepositTime[_beneficiary] = block.timestamp;
        emit Locked(_beneficiary, userDepositTime[_beneficiary], msg.value);
    }

    function release() external {
        require(userBalances[msg.sender] > 0 && userDepositTime[msg.sender] + lockTime <= block.timestamp);
        uint releaseValue = userBalances[msg.sender];
        userBalances[msg.sender] = 0;
        userDepositTime[msg.sender] = 0;
        (bool success, ) = address(msg.sender).call{value: releaseValue}("");
        require(success, "Call failed");
        emit Released(msg.sender, releaseValue);
    }

    function getReleaseTime() external view returns(uint) {
        require(userBalances[msg.sender] > 0, "No deposit found");
        uint unlockTime = userDepositTime[msg.sender] + lockTime;
        if (block.timestamp >= unlockTime) {
            return 0;
        }
        return unlockTime - block.timestamp;
    }
}