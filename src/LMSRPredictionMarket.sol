// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {UD60x18, ud} from "@prb/math/UD60x18.sol";

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

    function buyYes(uint256 _amount) public {
        require(!resolved, "Market resolved");
        require(_amount > 0, "Amount must be > 0");

        uint256 costBefore = _cost(qYES, qNO);

        uint256 deltaQ = 0;
        uint256 step = 1e16; // 0.01 share per step

        while (true) {
            uint256 newCost = _cost(qYES + deltaQ + step, qNO);
            if (newCost - costBefore > _amount) {
                break;
            }
            deltaQ += step;
        }

        require(deltaQ > 0, "Amount too small");

        qYES += deltaQ;
        yesShares[msg.sender] += deltaQ;
    }

    function buyNo(uint256 _amount) public {}

    function priceYes() public view returns (uint256) {
        UD60x18 _b = ud(b);
        UD60x18 _qYes = ud(qYES);
        UD60x18 _qNo = ud(qNO);

        UD60x18 expYes = _qYes.div(_b).exp();
        UD60x18 expNo = _qNo.div(_b).exp();

        return expYes.div(expYes.add(expNo)).unwrap();
    }

    function priceNo() public view returns (uint256) {
        UD60x18 _b = ud(b);
        UD60x18 _qYes = ud(qYES);
        UD60x18 _qNo = ud(qNO);

        UD60x18 expYes = _qYes.div(_b).exp();
        UD60x18 expNo = _qNo.div(_b).exp();

        return expNo.div(expYes.add(expNo)).unwrap();
    }

    function cost() public view returns (uint256) {
        // C(q) = b * ln(e^(qYES/b) + e^(qNO/b))

        UD60x18 _b = ud(b);
        UD60x18 _qYes = ud(qYES);
        UD60x18 _qNo = ud(qNO);

        UD60x18 expYes = _qYes.div(_b).exp();
        UD60x18 expNo = _qNo.div(_b).exp();

        return _b.mul((expYes.add(expNo)).ln()).unwrap();
    }

    function _cost(
        uint256 _qYes,
        uint256 _qNo
    ) internal view returns (uint256) {
        UD60x18 _b = ud(b);
        UD60x18 qYes_ = ud(_qYes);
        UD60x18 qNo_ = ud(_qNo);

        UD60x18 expYes = qYes_.div(_b).exp();
        UD60x18 expNo = qNo_.div(_b).exp();

        return _b.mul((expYes.add(expNo)).ln()).unwrap();
    }

    function resolve(bool yesWins) public {}

    function claim() public {}
}
