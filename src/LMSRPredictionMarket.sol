// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract LMSRPredictionMarket {
    uint256 public b;
    uint256 public qYES;
    uint256 public qNO;

    mapping(address => uint256) public yesShares;
    mapping(address => uint256) public noShares;

    bool public resolved;
    bool public yesWon;

    function buyYes(uint256 _amount) public {}
}
