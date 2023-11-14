// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

contract GarageManager {

    error BadCarIndex(uint _index);

    struct Car {
        string make;
        string model;
        string color;
        uint numberOfDoors;
    }

    // A public mapping called garage to store a list of Cars, indexed by address
    mapping(address => Car[]) public garage;
    
    // Add a function called addCar that adds a car to the user's collection in the garage.
    // Use msg.sender to determine the owner
    // Accept arguments for make, model, color, and number of doors, and use those to create a new instance of Car
    // Add that Car to the garage under the user's address
    function addCar(string calldata _make, string calldata _model, string calldata _color, uint _numberOfDoors) public {
        Car memory _newCar = Car(_make, _model, _color, _numberOfDoors);
        garage[msg.sender].push(_newCar);
    }
    
    // Add a function called getMyCars.
    // It should return an array with all of the cars owned by the calling user.
    function getMyCars() public view returns (Car[] memory) {
        return garage[msg.sender];
    }

    // Add a function called getUserCars.
    // It should return an array with all of the cars for any given address.
    function getUserCars(address _address) public view returns (Car[] memory) {
        return garage[_address];
    }

    // Add a function called updateCar.
    // It should accept a uint for the index of the car to be updated,
    // and arguments for all of the Car types.
    // If the sender doesn't have a car at that index,
    // it should revert with a custom error BadCarIndex and the index provided.
    // Otherwise, it should update that entry to the new properties.
    function updateCar(uint _index, string calldata _make, string calldata _model, string calldata _color, uint _numberOfDoors) public {
        if (_index <= garage[msg.sender].length) {
            Car memory _newCar = Car(_make, _model, _color, _numberOfDoors);
            garage[msg.sender][_index] = _newCar;
        } else {
            revert BadCarIndex(_index);
        }
    }

    // Add a public function called resetMyGarage.
    // It should delete the entry in garage for the sender.
    function resetMyGarage() public {
        delete garage[msg.sender];
    }

}

