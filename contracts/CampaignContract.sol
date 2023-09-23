// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract CampaignContract {

    struct Campaign {
        address payable owner;
        uint256 goal;
        uint256 deadline;
        uint256 amount;
        uint256 participants;
        bool active;
    }


    function create(Campaign memory campaign) public {

    }


    function participate(uint256 campaignId) payable public {

    }



}