// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/LMSRPredictionMarket.sol";
import { UD60x18, ud } from "@prb/math/UD60x18.sol";

contract LMSRPredictionMarketTest is Test {
    using stdStorage for StdStorage;

    LMSRPredictionMarket public market;
    uint256 public constant B = 1000 ether; // 1000 * 1e18

    function setUp() public {
        market = new LMSRPredictionMarket(B);
    }

    function testInitialCost() public {
        // qYES = 0, qNO = 0
        // Cost = B * ln(e^0 + e^0) = B * ln(2)
        uint256 cost = market.cost();
        
        // expected = 1000 * ln(2)
        uint256 expected = ud(B).mul(ud(2e18).ln()).unwrap();
        
        // Allow small rounding error
        assertApproxEqAbs(cost, expected, 1e10);
    }

    function testInitialCostWith100Liquidity() public {
        uint256 b100 = 100 ether;
        LMSRPredictionMarket market100 = new LMSRPredictionMarket(b100);

        // Expected: 100 * ln(2)
        // ln(2) is approx 0.69314718056...
        // 100 * 0.6931... = 69.3147... ether
        
        uint256 cost = market100.cost();
        uint256 expected = ud(b100).mul(ud(2e18).ln()).unwrap();

        assertApproxEqAbs(cost, expected, 1e10);
    }

    function testCostAfterBuying10Yes() public {
        uint256 amount = 10 ether; // 10 YES tokens
        
        // Simulate buying by setting qYES storage directly (since buyYes is empty)
        // qYES is at slot 1 in the contract
        stdstore.target(address(market)).sig("qYES()").checked_write(amount);

        // Calculate Expected
        // C = b * ln(e^(10/b) + e^(0/b)) = b * ln(e^0.01 + 1)
        UD60x18 _b = ud(B);
        UD60x18 _qYes = ud(amount);
        UD60x18 _qNo = ud(0); // 0
        
        UD60x18 expYes = _qYes.div(_b).exp();
        UD60x18 expNo = _qNo.div(_b).exp(); // e^0 = 1
        
        // Expected value manually calculated in Solidity to verify contract logic
        uint256 expected = _b.mul( (expYes.add(expNo)).ln() ).unwrap();
        
        uint256 cost = market.cost();

        // assertAge(cost, expected); // Alias for assertEq but "approx" in spirit if we had drift
        assertApproxEqAbs(cost, expected, 1e10);
    }

    function testCostIncreasesWithShares() public {
        uint256 initialCost = market.cost();

        // Hack storage to increase qYES
        // qYES is at slot 1
        vm.store(address(market), bytes32(uint256(1)), bytes32(uint256(10 ether)));

        uint256 newCost = market.cost();
        assertGt(newCost, initialCost);
    }
}
