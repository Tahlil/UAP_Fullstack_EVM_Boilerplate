pragma solidity ^0.8.13;

contract Counter {
    uint256 public number;
    address public owner;
    uint256 public lastUpdateTimestamp;
    mapping(address => uint256) public userContributions;

    event NumberSet(uint256 newNumber, address setter);
    event NumberIncremented(uint256 newNumber, address incrementer);
    event NumberDecremented(uint256 newNumber, address decrementer);

    constructor() {
        owner = msg.sender;
        lastUpdateTimestamp = block.timestamp;
    }

    function setNumber(uint256 newNumber) public {
        number = newNumber;
        userContributions[msg.sender] = newNumber;
        lastUpdateTimestamp = block.timestamp;
        emit NumberSet(newNumber, msg.sender);
    }

    function increment() public {
        number++;
        userContributions[msg.sender]++;
        lastUpdateTimestamp = block.timestamp;
        emit NumberIncremented(number, msg.sender);
    }

    function decrement() public {
        require(number > 0, "Counter: cannot decrement below 0");
        number--;
        userContributions[msg.sender]++;
        lastUpdateTimestamp = block.timestamp;
        emit NumberDecremented(number, msg.sender);
    }

    function reset() public {
        require(msg.sender == owner, "Counter: only owner can reset");
        number = 0;
        lastUpdateTimestamp = block.timestamp;
    }

    function getUserContribution(address user) public view returns (uint256) {
        return userContributions[user];
    }
}