pragma solidity ^0.4.21;

import { Auction } from "./Auction.sol";

contract AuctionFactory {
    address[] public auctions;

    event AuctionCreated(address auctionContract, address owner, uint numAuctions, address[] allAuctions);

    constructor() public{
    }

    function createAuction(uint startBlock, uint endBlock) public {
        Auction newAuction = new Auction(msg.sender,startBlock, endBlock);
        auctions.push(newAuction);

        emit AuctionCreated(newAuction, msg.sender, auctions.length, auctions);
    }

    function allAuctions() public view returns (address[]) {
        return auctions;
    }
}