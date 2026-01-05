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

        // Binary search to find deltaQ
        uint256 deltaQ = _binarySearchShares(qYES, qNO, _amount, costBefore, true);
        require(deltaQ > 0, "Amount too small");

        // Calculate actual cost
        uint256 actualCost = _cost(qYES + deltaQ, qNO) - costBefore;
        require(actualCost <= _amount, "Cost exceeds amount");

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

    function _cost(uint256 _qYes, uint256 _qNo) internal view returns (uint256) {
        UD60x18 _b = ud(b);
        UD60x18 qYes_ = ud(_qYes);
        UD60x18 qNo_ = ud(_qNo);

        UD60x18 expYes = qYes_.div(_b).exp();
        UD60x18 expNo = qNo_.div(_b).exp();

        return _b.mul((expYes.add(expNo)).ln()).unwrap();
    }

    /**
     * @dev Binary search to find the maximum shares that can be bought with given amount
     * @param currentYes Current YES share quantity
     * @param currentNo Current NO share quantity
     * @param maxCost Maximum cost user is willing to pay
     * @param costBefore Cost function value before purchase
     * @param isYes Whether buying YES or NO shares
     * @return Maximum shares that can be purchased
     */
    function _binarySearchShares(
        uint256 currentYes,
        uint256 currentNo,
        uint256 maxCost,
        uint256 costBefore,
        bool isYes
    ) internal view returns (uint256) {
        uint256 left = 0;
        uint256 right = maxCost * 100; // Upper bound estimate
        uint256 result = 0;

        // Binary search with 50 iterations max (enough for precision)
        for (uint256 i = 0; i < 50; i++) {
            if (left > right) break;

            uint256 mid = (left + right) / 2;
            if (mid == 0) {
                left = 1;
                continue;
            }

            uint256 newCost;
            if (isYes) {
                newCost = _cost(currentYes + mid, currentNo);
            } else {
                newCost = _cost(currentYes, currentNo + mid);
            }

            if (newCost <= costBefore) {
                // Handle edge case where cost function is flat
                left = mid + 1;
                continue;
            }

            uint256 costDiff = newCost - costBefore;

            if (costDiff <= maxCost) {
                result = mid;
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }

        return result;
    }

    function resolve(bool yesWins) public {}

    function claim() public {}
}
