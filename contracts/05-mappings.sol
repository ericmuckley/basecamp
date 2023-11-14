// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

contract FavoriteRecords {

    error NotApproved(string _albumName);

    // A public mapping approvedRecords,
    // which returns true if an album name has been added as described below,
    // and false if it has not.
    mapping (string => bool) public approvedRecords;
    // A mapping called userFavorites that indexes user addresses
    // to a mapping of string record names which returns true or false,
    // depending if the user has marked that album as a favorite.
    mapping (address => string[]) public userFavorites;

    string[] internal approvedRecordsList = [
        "Thriller",
        "Back in Black",
        "The Bodyguard",
        "The Dark Side of the Moon",
        "Their Greatest Hits (1971-1975)",
        "Hotel California",
        "Come On Over",
        "Rumours",
        "Saturday Night Fever"
    ];

    constructor() {
        for (uint i = 0; i < approvedRecordsList.length; i++) {
            approvedRecords[approvedRecordsList[i]] = true;
        }
    }

    // Add a function called getApprovedRecords.
    // This function should return a list of all of the
    // names currently indexed in approvedRecords.
    function getApprovedRecords() public view returns (string[] memory) {
        return approvedRecordsList;
    }

    // Create a function called addRecord that accepts an album name as a parameter.
    // If the album is on the approved list, add it to the list under the address of the sender.
    // Otherwise, reject it with a custom error of NotApproved with the submitted name as an argument.
    function addRecord(string memory _albumName) public {
        if (approvedRecords[_albumName]) {
            userFavorites[msg.sender].push(_albumName);
        } else {
            revert NotApproved(_albumName);
        }
    }

    // Write a function called getUserFavorites that retrieves
    // the list of favorites for any address.
    function getUserFavorites(address _address) public view returns (string[] memory) {
        return userFavorites[_address];
    }

    // Add a function called resetUserFavorites that resets userFavorites for the sender.
    function resetUserFavorites() public {
        delete userFavorites[msg.sender];
    }

}

