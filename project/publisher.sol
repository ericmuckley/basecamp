// SPDX-License-Identifier: UNLICENSED

// TODO:
// add totalHashes; 
// add gethashesByCreator


pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v5.0/contracts/utils/structs/EnumerableSet.sol";

contract Publisher {

    error HashDoesNotExist(bytes32);
    error HashAlreadyExists(bytes32);

    using EnumerableSet for EnumerableSet.AddressSet;

    struct Item {
        string name;
        address creator;
        string description;
        uint blockCreated;
        bytes32 hash;
    }

    uint public totalHashes;
    bytes32[] internal allHashes;
    mapping(bytes32 => Item) public hashInfo;
    mapping(address => uint) public totalHashesByAddress;
    mapping(address => bytes32[]) public hashListByAddress;
    EnumerableSet.AddressSet internal allCreators;

    function createItem (
        string calldata _name,
        string calldata _description,
        uint8[] calldata _inputBytes
    ) public returns (uint) {

        bytes32 _hash = keccak256(abi.encode(_inputBytes));

        if (hashInfo[_hash].hash == _hash) {
            revert HashAlreadyExists(_hash);
        }

        totalHashes ++;
        allHashes.push(_hash);
        allCreators.add(msg.sender);
        totalHashesByAddress[msg.sender]++;
        hashListByAddress[msg.sender].push(_hash);
        hashInfo[_hash] = Item({
            name: _name,
            creator: msg.sender,
            description: _description, 
            blockCreated: block.number,    
            hash: _hash
        });

        return allHashes.length;
    }



    function getItemByHash(bytes32 _hash) public view returns (Item memory) {
        Item memory _item = hashInfo[_hash];
        if (_item.hash != _hash) {
            revert HashDoesNotExist(_hash);
        }
        return hashInfo[_hash];
    }


    function getHashListByAddress(address _address) public view returns (bytes32[] memory) {
        return hashListByAddress[_address];
    }

    function getAllHashes() public view returns (bytes32[] memory) {
        return allHashes;
    }

    function getAllCreators() public view returns (address[] memory) {
        return allCreators.values();
    }

    function getItemsByCreator(address _creatorAddress) public view returns (Item[] memory) {
        bytes32[] memory _hashes = hashListByAddress[_creatorAddress];
        Item[] memory _items = new Item[](_hashes.length);
        for (uint i; i < _items.length; i++) {
            _items[i] = hashInfo[_hashes[i]];
        }
        return _items;
    }
    
}
