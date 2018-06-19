pragma solidity ^0.4.21;

contract Auction {
    
    address public owner;
    uint public startBlock;
    uint public endBlock;

    bool public canceled;
    address public highestBidder;
    mapping(address => uint256) public fundsByBidder;

    event LogBid(address bidder, uint bid, address highestBidder, uint highestBid);
    event LogWithdrawal(address withdrawer, address withdrawalAccount, uint amount);
    event LogCanceled();

    constructor(address _owner, uint _startBlock, uint _endBlock) public {
    
        if (_startBlock >= _endBlock) revert();
        if (_startBlock < block.number) revert();
        if (_owner == 0) revert();

        owner = _owner;
        startBlock = _startBlock;
        endBlock = _endBlock;
    }

    function getHighestBid() public view returns (uint)
    {
        return fundsByBidder[highestBidder];
    }

    function placeBid() public payable onlyAfterStart
    onlyBeforeEnd onlyNotCanceled onlyNotOwner returns (bool success)
    {
        if (msg.value == 0) revert();

        uint newBid = fundsByBidder[msg.sender] + msg.value;
        uint highestBid = fundsByBidder[highestBidder];

        fundsByBidder[msg.sender] = newBid;

        if (newBid > highestBid) {
            if (msg.sender != highestBidder) {
                highestBidder = msg.sender;
            }
            highestBid = newBid;
        } else {
            revert();
        }

        emit LogBid(msg.sender, newBid, highestBidder, highestBid);
        return true;
    }

    function cancelAuction() public onlyOwner
    onlyBeforeEnd onlyNotCanceled returns (bool success)
    {
        canceled = true;
        emit LogCanceled();
        return true;
    }

    function withdraw() public onlyEndedOrCanceled returns (bool success)
    {
        address withdrawalAccount;
        uint withdrawalAmount;

        if (canceled) {
            withdrawalAccount = msg.sender;
            withdrawalAmount = fundsByBidder[withdrawalAccount];

        } else {
            if (msg.sender == owner) {
                withdrawalAccount = highestBidder;
                withdrawalAmount = fundsByBidder[highestBidder];

            } else if (msg.sender != highestBidder) {
                withdrawalAccount = msg.sender;
                withdrawalAmount = fundsByBidder[withdrawalAccount];
            } 
        }

        if (withdrawalAmount == 0) revert();

        fundsByBidder[withdrawalAccount] -= withdrawalAmount;

        msg.sender.transfer(withdrawalAmount);

        emit LogWithdrawal(msg.sender, withdrawalAccount, withdrawalAmount);

        return true;
    }

    modifier onlyOwner {
        if (msg.sender != owner) revert();
        _;
    }

    modifier onlyNotOwner {
        if (msg.sender == owner) revert();
        _;
    }

    modifier onlyAfterStart {
        if (block.number < startBlock) revert();
        _;
    }

    modifier onlyBeforeEnd {
        if (block.number > endBlock) revert();
        _;
    }

    modifier onlyNotCanceled {
        if (canceled) revert();
        _;
    }

    modifier onlyEndedOrCanceled {
        if (block.number < endBlock && !canceled) revert();
        _;
    }
}