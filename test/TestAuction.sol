pragma solidity ^0.4.21;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Auction.sol";

contract TestAuction {
    uint public initialBalance = 10 ether;
    Auction auction;

    function beforeAll() public {
        auction = new Auction(msg.sender,block.number, block.number+1000);
    }

    function testHighestBidMultipleBids() public {
        auction.placeBid.value(1 ether)();
        auction.placeBid.value(2 ether)();

        uint highestBid = auction.getHighestBid();
        Assert.equal(highestBid,3 ether,"Highest bid should be 3 ether");
    }

    function testBidWhenAuctionHasntStartedShouldRevert() public {
        Auction auctionInTheFuture = new Auction(msg.sender,block.number+1000,block.number+1222);
        /*
        ThrowProxy throwProxy = new ThrowProxy(address(auctionInTheFuture));
        Auction(address(throwProxy)).placeBid.value(1 ether)();
        bool r = throwProxy.execute.gas(200000)();
        */
        bool r = auctionInTheFuture.call(bytes4(bytes32(keccak256("placeBid.value(1 ether)()"))));
        Assert.isFalse(r, "Should be false because it reverts");
    }
}

contract ThrowProxy {
    address public target;
    bytes data;

    constructor(address _target) public {
        target = _target;
    }

    function() public {
        data = msg.data;
    }

    function execute() public returns (bool) {
        return target.call(data);
    }
}