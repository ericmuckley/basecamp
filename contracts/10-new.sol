// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/access/Ownable.sol";

// Create an Ownable contract called AddressBook. In it include:
contract AddressBook is Ownable {

    error ContactNotFound(uint _id);

    struct Contact {
        uint id;
        string firstName;
        string lastName;
        uint[] phoneNumbers;
    }
    Contact[] public contacts;

    // The addContact function should be usable only by the owner of the contract.
    // It should take in the necessary arguments to add a given contact's information to contacts
    function addContact(
        uint _id,
        string calldata firstName,
        string calldata lastName,
        uint[] calldata phoneNumbers
    ) public onlyOwner {
        Contact memory _newContact = Contact(_id, firstName, lastName, phoneNumbers);
        contacts.push(_newContact);
    }

    // The deleteContact function should be usable only by the owner and
    // should delete the contact under the supplied _id number.
    // If the _id is not found, it should revert with an error called ContactNotFound
    // with the supplied id number.
    function deleteContact(uint _id) public onlyOwner {
        for (uint i; i < contacts.length; i++) {
            if (contacts[i].id == _id) {
                delete contacts[i];
                return;
            }
        }
        revert ContactNotFound(_id);
    }

    // The getContact function returns the contact information of the supplied _id number.
    // It reverts with ContactNotFound if the contact isn't present.
    function getContact(uint _id) public view returns (Contact memory) {
        for (uint i; i < contacts.length; i++) {
            if (_id == contacts[i].id) {
                return contacts[i];
            }
        }
        revert ContactNotFound(_id);
    }

    function getAllContacts() public view returns (Contact[] memory) {
        return contacts;
    }

}

contract AddressBookFactory {
    function deploy() public returns (address) {
        AddressBook newContract = new AddressBook();
        return address(newContract);
    }
}
