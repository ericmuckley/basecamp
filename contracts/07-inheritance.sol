// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

// Create an abstract contract called employee. It should have:
// A public variable storing idNumber
// A public variable storing managerId
// A constructor that accepts arguments for and sets both of these variables
// A virtual function called getAnnualCost that returns a uint
abstract contract Employee {
    uint public idNumber;
    uint public managerId;
    constructor(uint _idNumber, uint _managerId) {
        idNumber = _idNumber;
        managerId = _managerId;
    }
    function getAnnualCost() public virtual view returns (uint);
}

// A contract called Salaried. It should:
// Inherit from Employee
// Have a public variable for annualSalary
// Implement an override function for getAnnualCost that returns annualSalary
// An appropriate constructor that performs any setup, including setting annualSalary
contract Salaried is Employee {
    uint public annualSalary;
    constructor(uint _annualSalary, uint idNumber, uint managerId) Employee(idNumber, managerId) {
        annualSalary = _annualSalary;
    }
    function getAnnualCost() public override view returns (uint) {
        return annualSalary;
    }
}

// Implement a contract called Hourly. It should:
// Inherit from Employee
// Have a public variable storing hourlyRate
// Include any other necessary setup and implementation
contract Hourly is Employee {
    uint public hourlyRate;
    constructor(uint _hourlyRate, uint idNumber, uint managerId) Employee(idNumber, managerId) {
        hourlyRate = _hourlyRate;
    }
    function getAnnualCost() public override view returns (uint) {
        return hourlyRate * 2080;
    }
}

// Implement a contract called Manager. It should:
// Have a public array storing employee Ids
// Include a function called addReport that can add id numbers to that array
// Include a function called resetReports that can reset that array to empty
contract Manager {
    uint[] public employeeIds;
    function addReport(uint _newId) public {
        employeeIds.push(_newId);
    }
    function resetReports() public {
        delete employeeIds;
    }
}

// Implement a contract called Salesperson that inherits from Hourly.
contract Salesperson is Hourly {
    constructor(uint hourlyRate, uint idNumber, uint managerId) Hourly(hourlyRate, idNumber, managerId) {}
}

// Implement a contract called EngineeringManager that inherits from Salaried and Manager.
contract EngineeringManager is Salaried, Manager {
    constructor (uint annualSalary, uint idNumber, uint managerId) Salaried(annualSalary, idNumber, managerId) {}
}


// Deploy your Salesperson and EngineeringManager contracts. Use the following values:

// Salesperson
// Hourly rate is 20 dollars an hour
// Id number is 55555
// Manager Id number is 12345

// Manager
// Annual salary is 200,000
// Id number is 54321
// Manager Id is 11111

// Copy the below contract and deploy it using the addresses of your
// Salesperson and EngineeringManager contracts.
contract InheritanceSubmission {
    address public salesPerson;
    address public engineeringManager;

    constructor(address _salesPerson, address _engineeringManager) {
        salesPerson = _salesPerson;
        engineeringManager = _engineeringManager;
    }
}