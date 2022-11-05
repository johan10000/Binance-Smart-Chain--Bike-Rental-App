// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title BikeChain
 * @dev A bike rental on blockchain
 */
contract BikeChain {

    // set the owner of the smart contract

    address owner;

    constructor()
    {
        owner = msg.sender; // set owner as te deployer of the smart contract
    }

    // Add yourself as customer - Renter

    struct Renter
    {
        address payable walletAddress; // wallet address of renter
        string firstName; // first name of renter
        string lastName; // last name of renter
        bool canRent; // is the renter allowed to rent or not
        bool active; // are they currently on the bike or not
        uint balance; // balance in renter's wallet
        uint due; // the amount they have to pay
        uint start; // the start time for renter when it rents a bike
        uint end; // the end time for renter when it returns a bike
    }

    mapping(address => Renter) public renters; // here is the wallet address, give me the renter

    function addRenter(address payable walletAddress, string memory firstName, string memory lastName, bool canRent, bool active, uint balance, uint due, uint start, uint end) public
    {
        renters[walletAddress] = Renter(walletAddress, firstName, lastName, canRent, active, balance, due, start, end);
    }

    // Check out the bike to ride around

    function checkOut(address walletAddress) public
    {
        require(renters[walletAddress].due==0, "You have dues pending");
        require(renters[walletAddress].canRent==0, "You already have a bike, so you cannot rent");
        renters[walletAddress].active = true; // hey i checkout a bike
        renters[walletAddress].start = block.timestamp;
        renters[walletAddress].canRent = false; // this person cannot rent a bike because they already have one
    }

    // Check in the bike, to return the bike

    function checkIn(address walletAddress) public
    {
        require(renters[walletAddress].active==true, "Please check out a bike first");

        renters[walletAddress].active = false; // hey i checkout a bike
        renters[walletAddress].end = block.timestamp;

        // set the amount due
        setDue(walletAddress);

        // renters[walletAddress].canRent = true; // this person cannot rent a bike because they already have one
    }

    // Get total duration of bike used

    function renterTimeSpan(uint start, uint end) internal pure returns(uint)
    {
        return end-start; // for how much time the bike was rented, in seconds
    }

    function getTotalDuration(address walletAddress) public view returns(uint)
    {
        require(renters[walletAddress].active==false, "Bike is curreently check out");

        uint timespan=renterTimeSpan(renters[walletAddress].start, renters[walletAddress].end); // for how much time the bike was rented, in seconds
        uint timespanInMinutes = timespan/60; // or how much time the bike was rented, in minutes
        return timespanInMinutes;
    }

    // Get contract balance(my company's balance)

    function balanceOf() view public returns(uint)
    {
        return address(this).balance; // accept it! memorize it! it returns the balance of this contract
    }

    // Get cutomer's - renter's balance

    function balanceOf(address walletAddress) view public returns(uint)
    {
        return renters[walletAddress].balance;
    }

    // Set due amount
    // every five minutes i will charge 2 dollars

    function setDue(address walletAddress) internal
    {
        uint timespanInMinutes = getTotalDuration(walletAddress);
        uint fiveMinuteIncrements = timespanInMinutes/5;
        renters[walletAddress].due = fiveMinuteIncrements * 5000000000000000;
    }

    // hey can i rent the bike

    function canRentBike(address walletAddress) public view returns(bool)
    {
        return renters[walletAddress].canRent;
    }

    // Renter depositing money to it's account, also tis money will be added to my company's smart contract balance already

    function deposit(address walletAddress) payable public
    {
        renters[walletAddress].balance = renters[walletAddress].balance + msg.value;
    }

    // Renter makes payment of due amount, also tis money will be deducted from my company's smart contract balance already

    function makePayment(address walletAddress) payable public
    {
        require(renters[walletAddress].due>0, "You have nothing to pay");
        require(renters[walletAddress].balance>msg.value, "You do not ave enough funds to cover payments, please make a deposit");
        renters[walletAddress].balance = renters[walletAddress].balance - msg.value;
        renters[walletAddress].canRent = true;
        renters[walletAddress].due = 0;
        renters[walletAddress].start=0;
        renters[walletAddress].end=0;
    }
}
