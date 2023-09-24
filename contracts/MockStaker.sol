pragma solidity ^0.8.0;

contract MockStaker {

    uint256 public balance;
    uint256 public staked;
    constructor(uint256 _balance) payable {
        balance = _balance;
    }

    function stake() public payable {
        staked = msg.value;
        collectInterest();
    }

    //Needs to be called in test
    function collectInterest() public {
        staked += staked/5;
    }

    function withdraw(uint256 amount) public {
        payable(msg.sender).transfer(amount);
        staked -= amount;
    }

    function withdrawAll() public returns (uint256 s) {
        payable(msg.sender).transfer(staked);
        return s;
    }
}
