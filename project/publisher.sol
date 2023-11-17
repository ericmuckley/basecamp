// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

contract Publisher {

    struct Item {
        string hash;
        string name;
        //string dateModified;
        uint blockCreated;
        address creator;
        string description;
    }

    string[] public allHashes;
    mapping(string => Item) public hashInfo;
    mapping(address => string[]) internal itemsByCreator;


    function createItem (
        string calldata _hash,
        string calldata _name,
        string calldata _description
    ) public returns (uint) {

        Item memory _newItem = Item({
            hash: _hash,
            name: _name,
            blockCreated: block.number,
            creator: msg.sender,
            description: _description
        });

        allHashes.push(_hash);
        hashInfo[_hash] = _newItem;
        itemsByCreator[msg.sender].push(_hash);

        return allHashes.length;
    }

    function getItemHashesByCreator(address _creatorAddress) public view returns (string[] memory) {
        return itemsByCreator[_creatorAddress];
    }

    

}
