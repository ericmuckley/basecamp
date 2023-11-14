// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

contract EmployeeStorage {

    // A private variable shares storing the employee's number of shares owned.
    // Employees with more than 5,000 shares count as directors and are stored in another contract
    uint16 private shares;

    // A private variable salary storing the employee's salary
    // Salaries range from 0 to 1,000,000 dollars
    uint24 private salary;

    // A public variable idNumber storing the employee's ID number
    // Employee numbers are not sequential, so this field should allow any number up to 2^256-1
    uint public idNumber;

    // Public variable name which store the employee's name
    string public name;

    error TooManyShares(uint _newTotalShares);

    constructor () {
        name = "Pat";
        shares = 1000;
        salary = 50000;
        idNumber = 112358132134;
    }

    function viewSalary() external view returns (uint24) {
        return salary;
    }

    function viewShares() external view returns (uint16) {
        return shares;
    }

    function grantShares(uint16 _newShares) public {
        /**
        * Add the provided number of shares to the shares.
        * If this would result in more than 5000 shares,
        * revert with a custom error called TooManyShares
        * that returns the number of shares the employee
        * would have with the new amount added.

        * If the number of _newShares is greater than 5000,
        * revert with a string message, "Too many shares".
        **/
        if (_newShares > 5000) {
            revert("Too many shares");
        } else if (_newShares + shares > 5000) {
            revert TooManyShares(_newShares + shares);
        } else {
            shares += _newShares;
        }
    }


    /**
    * Do not modify this function.  It is used to enable the unit test for this pin
    * to check whether or not you have configured your storage variables to make
    * use of packing.
    *
    * If you wish to cheat, simply modify this function to always return `0`
    * I'm not your boss ¯\_(ツ)_/¯
    *
    * Fair warning though, if you do cheat, it will be on the blockchain having been
    * deployed by you wallet....FOREVER!
    */
    function checkForPacking(uint _slot) public view returns (uint r) {
        assembly {
            r := sload (_slot)
        }
    }

    /**
    * Warning: Anyone can use this function at any time!
    */
    function debugResetShares() public {
        shares = 1000;
    }

}



