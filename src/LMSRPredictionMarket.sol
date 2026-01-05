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
    bool public marketCreated;

    constructor(uint256 _b) {
        b = _b;
        marketCreated = true;
    }

    function buyYes(uint256 _amount) public {}

    function buyNo(uint256 _amount) public {}

    function priceYes() public view returns (uint256 price_) {}

    function priceNo() public view returns (uint256 price_) {}

    function resolve(bool yesWins) public {}

    function claim() public {}
}
