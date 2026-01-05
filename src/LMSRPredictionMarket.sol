// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { UD60x18, ud } from "@prb/math/UD60x18.sol";

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
        require(_b > 0, "b must be > 0");

        b = _b;
        marketCreated = true;
    }

    function buyYes(uint256 _amount) public {}

    function buyNo(uint256 _amount) public {}

    function priceYes() public view returns (uint256 price_) {}

    function priceNo() public view returns (uint256 price_) {}

    function cost() public view returns (uint256) {
        // C(q) = b * ln(e^(qYES/b) + e^(qNO/b))
        
        UD60x18 _b = ud(b);
        UD60x18 _qYes = ud(qYES);
        UD60x18 _qNo = ud(qNO);

        UD60x18 expYes = _qYes.div(_b).exp();
        UD60x18 expNo = _qNo.div(_b).exp();

        return _b.mul((expYes.add(expNo)).ln()).unwrap();
    }

    function resolve(bool yesWins) public {}

    function claim() public {}
    
}
