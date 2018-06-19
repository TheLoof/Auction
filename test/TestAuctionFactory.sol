pragma solidity ^0.4.21;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/AuctionFactory.sol";
import "../contracts/Auction.sol";

contract TestAuctionFactory {

    function testAuctionCreated() public {
        AuctionFactory af = AuctionFactory(DeployedAddresses.AuctionFactory());
        af.createAuction(block.number,block.number+1000);
        
        uint auctions = af.allAuctions().length;
        Assert.equal(auctions,1,"There should be only one auction active");
    }
}