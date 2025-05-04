// SPDX-License-identifier: MIT
pragma solidity ^0.8.24;

contract MiniVault {
    mapping(address => uint256) private userBalances;
    uint8 public interest;
    address private owner;
    
    constructor(uint8 _interest) {
        owner = msg.sender;
        require(_interest <= 100, "Interest too high");
        interest = _interest;
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

    function interestModifier(uint8 _newInterest) external onlyOwner() {
        require(_newInterest <= 100, "Interest too high");
        interest = _newInterest;
    }

    function deposit() external payable {
        require(msg.value > 0, "Deposit must be a positive value");
        userBalances[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amount) external {
        require(userBalances[msg.sender] > 0 && userBalances[msg.sender] >= _amount, "Balance too low");
        userBalances[msg.sender] -= _amount;
        uint256 withdrawWithInterest = _amount + (_amount * interest /  100);
        (bool success, ) = address(msg.sender).call{value: withdrawWithInterest}("");
        require(success, "Transfer failed");
    }

    receive() external payable {}
}
