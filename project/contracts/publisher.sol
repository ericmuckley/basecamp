// SPDX-License-Identifier: UNLICENSED

/*

Suggested changes from Michael

- enumerable set for all hashes, instead of array with counter
- not error for hasExists, but maybe return true
- do we actually need all the mappings, and addresses? whats the use case
- emit events for new item creation, then you don't need to keep track of the other indexes/mappings

*/

pragma solidity ^0.8.20;

//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v5.0/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract Publisher {

    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    struct Item {
        string name;
        address creator;
        string description;
        uint blockCreated;
        bytes32 hash;
    }

    event ItemCreated(Item indexed _item);
    
    mapping(bytes32 => Item) public hashInfo;
    mapping(address => bytes32[]) public hashListByAddress;
    EnumerableSet.AddressSet internal allCreators;
    EnumerableSet.Bytes32Set internal allHashes;

    function createItem (
        string calldata _name,
        string calldata _description,
        uint8[] calldata _inputBytes
    ) public returns (bytes32) {

        bytes32 _hash = keccak256(abi.encode(_inputBytes));

        if (hashInfo[_hash].hash != _hash) {
            allHashes.add(_hash);
            allCreators.add(msg.sender);
            hashListByAddress[msg.sender].push(_hash);
            Item memory _item = Item({
                name: _name,
                creator: msg.sender,
                description: _description, 
                blockCreated: block.number,    
                hash: _hash
            });
            hashInfo[_hash] = _item;
            emit ItemCreated(_item);
        }
        return _hash;
    }


    function getItemByHash(bytes32 _hash) public view returns (Item memory) {
        return hashInfo[_hash];
    }

    function getHashListByAddress(address _address) public view returns (bytes32[] memory) {
        return hashListByAddress[_address];
    }

    function getAllHashes() public view returns (bytes32[] memory) {
        return allHashes.values();
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