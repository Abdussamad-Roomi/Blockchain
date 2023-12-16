//SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.8.0;

 contract auction {
    address payable  owner;
    address highestBidder;
    uint256 startingTime;
    uint256 endingTime;
    event LogUint(uint number);
    mapping(address => uint256) public bids;
    uint highestBindingBid;
    address[] public bidKeys;
    


    
    function placeBids() payable  external {
    
        require(block.timestamp >= startingTime, "Auction has not started");
        require(block.timestamp < endingTime, "Auction has ended");
        require(msg.value > highestBindingBid, "Bid is not high enough");



        bool check = false;

        if (msg.value > bids[highestBidder]) {

             for (uint i = 0; i < bidKeys.length; i++) {
                if (bidKeys[i] == msg.sender) {
                check = true;
                break;
            }
        }
        if(check == true){
            highestBidder = msg.sender;
            bids[msg.sender] = msg.value;
            highestBindingBid = msg.value;
        }
        else{
            bidKeys.push(msg.sender);
            highestBidder = msg.sender;
            bids[msg.sender] = msg.value;
            highestBindingBid = bids[highestBidder];
        }

            
        }
    }
    

    function currentHigestBid() public  view returns (uint256) {
        return highestBindingBid;

    }


   function setStartTime(uint time) private  OnlyOwner{
        startingTime = time;
   }


   function setEndTime(uint time) private  OnlyOwner{
        endingTime = time;
   }
    constructor(uint _startTime, uint _endTime) public  {
            owner = payable(msg.sender);
            setEndTime(_endTime);
            setStartTime(_startTime);
         
        }





   modifier  OnlyOwner() {
        require(msg.sender == owner);
        //require(block.timestamp > startingTime);
    
    _;
   }



  function cancelAuction() external payable  OnlyOwner {
        require(block.timestamp < endingTime, "Auction already ended");
     
        for (uint i = 0; i < bidKeys.length; i++) {
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
 function finalizeAuction() external payable  OnlyOwner {
        require(block.timestamp >= endingTime, "Auction not yet ended");
        
        // Refund the remaining bids to the bidders
     
           for (uint i = 0; i < bidKeys.length; i++) {
            address payable bidder = payable(bidKeys[i]);
            uint amount = bids[bidder];
            if ((amount > 0) && (bidder != highestBidder)) {
                bids[bidder] = 0;
                bidder.transfer(amount);
                

            }
        }
     
        selfdestruct(owner);
    }

 }
