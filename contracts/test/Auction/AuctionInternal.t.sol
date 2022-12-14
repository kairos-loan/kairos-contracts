pragma solidity ^0.8.0;

import "../Commons/Internal.sol";


contract TestAuctionInternal is Internal {
    using RayMath for Ray;
    using RayMath for uint256;
    //Test with fuzzing but high valued convert into HEX


    function testPrice() public {
        Protocol storage proto = protocolStorage();

        proto.auctionPriceFactor = ONE.mul(3);
        proto.auctionDuration = 3 days;

        uint256 fuzeLent = 101832;
        Ray shareLent = Ray.wrap(3);
        uint256 timeElapsed = 1 days;

        uint256 res = price(fuzeLent, shareLent, timeElapsed);

        uint256 estimRes = (fuzeLent.div(shareLent)).mul(proto.auctionPriceFactor);
        uint256 finalEstimRes = estimRes.mul(ONE.sub(timeElapsed.div(proto.auctionDuration)));
        assertEq(res, finalEstimRes);

        timeElapsed = 3 days + 1 seconds;
        res = price(fuzeLent, shareLent, timeElapsed);
        assertEq(res, 0);
    }

}