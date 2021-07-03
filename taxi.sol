pragma solidity ^0.4.6;

contract taxi{
    
    struct Participants{
        address addr;
        uint balance;
        uint buying;
        uint selling;
        uint forDriver;
    }
    
    struct TaxiDriver{
        uint salary;
        address addressOfDriver;
        uint approvalState;
        uint doesExist;
    }
    
    struct OwnedCar{
        uint32 number;
        uint carID;
    }
    
    struct ProposedCar{
        uint carID;
        uint price;
        uint validTime;
        uint approvalState;
    }
    
    struct ProposedRepurchase{
        uint carID;
        uint price;
        uint validTime;
        uint approvalState;
    }
    
    modifier onlyManager(){
        require(manager == msg.sender);
        _;
    }
    
    modifier onlyCarDealer(){
        require(carDealer == msg.sender);
        _;
    }
    
    modifier onlyParticipant(){
        require(participants[msg.sender].addr != address(0));
        _;
    }
    
    modifier onlyDriver(){
        require(driver.addressOfDriver == msg.sender);
        _;
    }
    
    mapping(address => Participants) participants;
    
    address private manager;
    address private carDealer;
    uint contractBalance;
    uint participationFee;
    uint numberOfParticipants;
    uint fixedExpenses;
    TaxiDriver driver;
    TaxiDriver propDriver;
    OwnedCar ownedCar;
    ProposedCar propCar;
    ProposedRepurchase repurch;
    uint profit;
    uint createTime;
    uint offerTime;
    uint timeForSalary;
    uint timeForExpenses;
    
    constructor() public{
        manager = msg.sender;
        ownedCar.carID = 0;
        contractBalance = 0 ether;
        participationFee = 100 ether;
        driver.doesExist = 0;
        propDriver.doesExist = 0;
        fixedExpenses = 10 ether;
        profit = 0 ether;
        createTime = now;
        timeForExpenses = now;
    }
    
    function join() public payable {
        require(numberOfParticipants <= 9);
        participants[msg.sender] = Participants(msg.sender,msg.value, 0, 0, 0);
        numberOfParticipants++;
        contractBalance += participationFee;
        participants[msg.sender].balance -= participationFee;
    }
    
    function setCarDealer(address addressOfCarDealer) onlyManager public{
        carDealer = addressOfCarDealer;
    }
    
    function carProposeToBusiness(uint _carId,uint _price,uint _validTime) onlyCarDealer public{
        propCar = ProposedCar(_carId, _price, _validTime, 0);
        offerTime = now;
    }
    
    function approvePurchaseCar() public{
        require(participants[msg.sender].buying == 0);
        propCar.approvalState++; 
        participants[msg.sender].buying = 1;
        participants[msg.sender].selling = 0;
        
    }
    
    function purchaseCar() onlyManager public{
        require(offerTime <= propCar.validTime);
        require(propCar.approvalState > numberOfParticipants/2);
        ownedCar.carID = propCar.carID;
        contractBalance -= propCar.price;
    }
    
    function repurchaseCarPropose(uint _carId, uint _price, uint _validTime) onlyCarDealer public{
        repurch = ProposedRepurchase(_carId, _price, _validTime, 0);
        offerTime = now;
    }
    
    function approveSellProposal() public{
        require(participants[msg.sender].selling == 0);
        repurch.approvalState++;
        participants[msg.sender].selling = 1;
        participants[msg.sender].buying = 0;
        
    }
    
    function repurchaseCar() onlyCarDealer public{
        require(offerTime <= repurch.validTime);
        require(repurch.approvalState > numberOfParticipants/2);
        ownedCar.carID = 0;
        contractBalance += repurch.price;
    }
    
    function proposeDriver(address _addressOfDriver, uint _salary) onlyManager public{
        require(driver.doesExist == 0);
        propDriver.addressOfDriver = _addressOfDriver;
        propDriver.salary = _salary;
        propDriver.doesExist = 1;
    }
    
    function approveDriver() public{
        require(participants[msg.sender].forDriver == 0);
        propDriver.approvalState++;
        participants[msg.sender].forDriver = 1;
    }
    
    function setDriver () onlyManager public{
        if ( propDriver.approvalState > numberOfParticipants/2){
            driver = propDriver;
            driver.doesExist = 1;
            timeForSalary = now;
        }
    }
    
    function fireDriver() onlyManager public payable{
        require(propDriver.doesExist == 1);
        driver.salary += msg.value;
        propDriver.addressOfDriver = 0;
        driver.doesExist = 0;
        propDriver.doesExist = 0;
        
    }
    
    function payTaxiCharge() public payable{
        contractBalance += msg.value;
    }
    
    function releaseSalary() onlyManager public payable{
        require(timeForSalary == 30 days);
        timeForSalary = now;
        driver.salary += msg.value;
        contractBalance -= msg.value;
    }
    
    function getSalary() onlyDriver public view returns(uint){
        require(driver.salary > 0);
        return driver.salary;
    }
    
    function payCarExpenses() onlyManager public {
        require(timeForExpenses == 180 days);
        timeForExpenses = now;
        contractBalance -= fixedExpenses;
    }
    
    function payDividend() onlyManager public payable{
        require( createTime == 180 days);
        createTime = now;
        profit = contractBalance/numberOfParticipants;
    }
    
    function getDividend() onlyParticipant public payable{
        require( profit > 0);
        participants[msg.sender].balance += profit;
        contractBalance -= profit;
    }
    
    function () external{
        revert();
    }
    
}