// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


contract Escrow {
    enum Status {
        pending,
        orderConfirmed,
        shipping,
        Accepted,
        Rejected,
        Canceled
    }
    Status public status;
    address payable public buyer;
    address payable public seller;


    constructor() {
        status = Status.pending;
        seller = payable(msg.sender);
    }


    modifier onlyBuyer() {
        require(msg.sender == buyer, "only buyer can access");
        _;
    }


    modifier onlySeller() {
        require(msg.sender == seller, "only seller can access");
        _;
    }


    function buy() public payable returns (bool) {
        // require(msg.sender!=seller,"seller cannot buy");
        require(msg.value == 1 ether, "one ether please");
        buyer = payable(msg.sender);
        return true;
    }


    function confirmOrder() public onlySeller {
        require(buyer != address(0), "need buyer");
        require(status == Status.pending, "order cannot confirm");
        status = Status.orderConfirmed;
    }


    function shipping() public onlySeller {
        require(status == Status.orderConfirmed, "order is not confirmrd yet");
        status = Status.shipping;
    }


    // function delivered()public onlySeller


    function acceptedByBuyer() public onlyBuyer {
        require(status == Status.shipping, "order is not delivered yet");
        status = Status.Accepted;
    }


    function transferToSeller() public onlySeller {
        require(status == Status.Accepted, "order is not accepted yet");
        seller.transfer(address(this).balance);
    }


    function reset() public {
        require(
            status == Status.Accepted ||
                status == Status.Canceled ||
                status == Status.Rejected,
            "Cannot reset ongoing order"
        );
        delete status;
        delete buyer;
    }


    function rejectOrder() public onlySeller {
        status = Status.Rejected;
        buyer.transfer(address(this).balance);
        // delete status;
    }


    function canceleOrder() public onlyBuyer {
        status = Status.Canceled;
        buyer.transfer(address(this).balance);
        // delete status;
    }
}
