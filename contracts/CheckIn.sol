// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract CheckIn {
    //Define a struct for the Visitors
    struct Visitor {
        uint256 Id;
        string name;
        string contact;
        string recipient;
        string purpose;
        uint256 timeIn;
        uint256 timeOut;
        bytes32 signature;
        bool isCheckedIn;
        bool isCheckedOut;
    }

    //Create a global variable
    uint256 public totalVisitors;
    address public owner;
    //Create a mapping to store the Visitors
    mapping(uint256 => Visitor) public visitors;
    Visitor public checkinvisitors;

    //Define events to be triggered
    event NewVisitorAdded(string _name, uint256 _id, bool isCheckedIn);
    event CheckInSuccessful(address _user);
    event CheckOutFailed(bytes32 _errorMessage);

    //Modifier to restrict access to a function
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized!");
        _;
    }

    //Modifier to check if a Visitor has checked in
    modifier isVisitorCheckedIn(uint256 Id) {
        require(visitors[Id].Id >= 1, "Visitor Id not found");
        require(
            visitors[Id].isCheckedIn == true,
            "This visitor has already checked out!"
        );
        _;
    }

    //Modifier to check if a Visitors Id is valid
    modifier isIdValid(uint256 Id) {
        require(visitors[Id].Id >= 1, "Visitor Id not found");
        _;
    }

    //Modifier to check if a visitor has checked in
    modifier isVisitorNotCheckedIn(uint256 Id) {
        require(
            !visitors[Id].isCheckedIn && visitors[Id].timeOut == 0,
            "This visitor has not checked out!"
        );
        _;
    }

    //Constructor function that sets the owner of the contract to msg.sender
    constructor() {
        owner = msg.sender;
    }

    //Define a function to create a visitor
    function addVisitor(
        string memory _name,
        string memory _contact,
        string memory _recipient,
        string memory _purpose
    ) public {
        totalVisitors++;
        visitors[totalVisitors] = Visitor({
            Id: totalVisitors,
            name: _name,
            contact: _contact,
            recipient: _recipient,
            purpose: _purpose,
            timeIn: block.timestamp,
            timeOut: 0,
            signature: "",
            isCheckedIn: true,
            isCheckedOut: false
        });
        emit NewVisitorAdded(_name, totalVisitors, true);
    }

    //Define a function to get the visitor's details
    function getVisitorDetails(uint256 _id)
        public
        view
        isIdValid(_id)
        returns (Visitor memory)
    {
        return (visitors[_id]);
    }

    //Define a function to update the visitor's name
    function updateVisitorDetails(
        uint256 Id,
        string memory _name,
        string memory _contact,
        string memory _recipient,
        string memory _purpose
    )
        public
        isIdValid(Id) // onlyOwner
    {
        // require(Id <= totalVisitors, "The visitor does not exist!");
        visitors[Id].name = _name;
        visitors[Id].contact = _contact;
        visitors[Id].recipient = _recipient;
        visitors[Id].purpose = _purpose;
        emit NewVisitorAdded(_name, totalVisitors, true);
    }

    //Define a function to get the total number of visitors
    function getTotalVisitors() public view returns (uint256) {
        return totalVisitors;
    }

    //Define a function to get the visitor's signature
    function getVisitorSignature(uint256 _id)
        public
        view
        isVisitorCheckedIn(_id)
        returns (bytes32)
    {
        return bytes32(visitors[_id].signature);
    }

    //Define a function to update the visitor's signature
    function updateVisitorSignature(uint256 Id, bytes32 _signature)
        public
        onlyOwner
        isVisitorCheckedIn(Id)
    {
        require(Id <= totalVisitors, "The visitor does not exist!");
        visitors[Id].signature = _signature;
        emit NewVisitorAdded("", totalVisitors, true);
    }

    //Define a function to allow a visitor to check-out
    function checkOut(uint256 Id) public isVisitorCheckedIn(Id) {
        require(Id <= totalVisitors, "The visitor does not exist");
        require(!visitors[Id].isCheckedOut, "You have already checked out");
        // visitors[Id].isCheckedIn = false;
        visitors[Id].isCheckedOut = true;
        visitors[Id].timeOut = block.timestamp;
        emit CheckInSuccessful(msg.sender);
    }

    //Define a function for a failed checkout
    function checkOutFailed(uint256 Id) public {
        require(
            !visitors[Id].isCheckedIn &&
                visitors[Id].isCheckedOut &&
                visitors[Id].timeOut == 0,
            "This visitor is not checked in!"
        );
        emit CheckOutFailed("checkout failed");
    }
}
