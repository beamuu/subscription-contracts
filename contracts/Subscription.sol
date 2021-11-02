// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract Subscription {

    uint256     public      price;
    uint256     public      subscriptionPeriod;
    uint256     public      next;
    uint256     public      delay;
    uint        public      limit;
    uint        public      count;
    address     public      owner;
    address     public      reciever;
    address     public      token;
    address     public      spender;
    bool        public      active;
    bool        public      fail;
    

    modifier onlyReciever {
        require(msg.sender == reciever);
        _;
    }
    modifier onlySpender {
        require(msg.sender == spender);
        _;
    }
    modifier RoS {
        require(msg.sender == spender || msg.sender == reciever, "You don't have permission to perform this operation.");
        _;
    }
    modifier onlyActive {
        require(active == true, "Can be executed only when subscription is actived.");
        _;
    }
    
    constructor(
        uint256 _subscriptionPeriod, 
        address _reciever, 
        address _spender, 
        uint256 _price, 
        uint _limit, 
        address _token,
        uint256 _delay
    ) {
        owner = msg.sender;
        subscriptionPeriod = _subscriptionPeriod;
        
        count = 0;
        limit = _limit;
        reciever = _reciever;
        spender = _spender;
        token = _token;
        active = false;

        price - _price;
        delay = _delay;
    }
    function redeem() public onlyReciever onlyActive returns (bool) {
        require(block.timestamp < next, "Not in redemption period");
        require(count < limit || limit == 0, "Exceed the limitation");
        // transfer token here
        fail = true;
        IERC20(token).transferFrom(spender, reciever, price);
        fail = false;

        next = block.timestamp + subscriptionPeriod;
        return true;
    }
    function cancel() public RoS onlyActive returns (bool) {
        active = false;
        return true;
    }
    function transfer() public onlySpender onlyActive returns (bool) {
        require(block.timestamp < next, "Not in redemption period");
        require(count < limit || limit == 0, "Exceed the limitation");
        fail = true;
        IERC20(token).transferFrom(spender, reciever, price);
        fail = false;

        next = block.timestamp + subscriptionPeriod;
        return true;
    }
    function overdue() public view returns (bool) {
        if (block.timestamp > next + delay) {
            return true;
        }
        else {
            return false;
        }
    }
}