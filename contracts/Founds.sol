// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Founds {

    struct Campaign {
        address payable owner;
        uint256 goal;
        uint256 deadline;
        uint256 amount;
        uint256 participants;
        bool active;
    }

    constructor(){

    }


    function createCampaign() public {

    }


    function participate() payable public {

    }



}