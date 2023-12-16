// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

contract Auction {
    address payable public owner;
    address public highestBidder;
    uint256 public startingTime;
    uint256 public endingTime;
    event LogUint(uint256 number);
    mapping(address => uint256) public bids;
    uint256 public highestBindingBid;
    address[] public bidKeys;

    function placeBid() external payable {
        require(block.timestamp >= startingTime, "Auction has not started");
        require(block.timestamp < endingTime, "Auction has ended");
        require(msg.value > highestBindingBid, "Bid is not high enough");

        // Refund previous bidders with lower bids
        for (uint256 i = 0; i < bidKeys.length; i++) {
            address payable bidder = payable(bidKeys[i]);
            uint256 amount = bids[bidder];

            if (amount > 0 && amount < msg.value) {
                bids[bidder] = 0;
                bidder.transfer(amount);
            }
        }

        highestBidder = msg.sender;
        bids[msg.sender] = msg.value;
        highestBindingBid = msg.value;
        bidKeys.push(msg.sender);
    }

    function getCurrentHighestBid() public view returns (uint256) {
        return highestBindingBid;
    }

    function setStartTime(uint256 time) private onlyOwner {
        startingTime = time;
    }

    function setEndTime(uint256 time) private onlyOwner {
        endingTime = time;
    }

    constructor(uint256 _startTime, uint256 _endTime) {
        owner = payable(msg.sender);
        setEndTime(_endTime);
        setStartTime(_startTime);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function cancelAuction() external onlyOwner {
        require(block.timestamp < endingTime, "Auction already ended");

        for (uint256 i = 0; i < bidKeys.length; i++) {
            address payable bidder = payable(bidKeys[i]);
            uint256 amount = bids[bidder];

            emit LogUint(amount);

            if (amount > 0) {
                bids[bidder] = 0;
                bidder.transfer(amount);
            }
        }

        selfdestruct(owner);
    }

    function finalizeAuction() external onlyOwner {
        require(block.timestamp >= endingTime, "Auction not yet ended");

        for (uint256 i = 0; i < bidKeys.length; i++) {
            address payable bidder = payable(bidKeys[i]);
            uint256 amount = bids[bidder];
            if ((amount > 0) && (bidder != highestBidder)) {
                bids[bidder] = 0;
                bidder.transfer(amount);
            }
        }

        selfdestruct(owner);
    }
}
