// SPDX-License-Identifier: UNLICENSED


/*
Notes

- to create a root item, use bytes32(0) = 
0x0000000000000000000000000000000000000000000000000000000000000000
for the parentHash.

- sample data value ("hello") in bytes32:
0x68656c6c6f000000000000000000000000000000000000000000000000000000

*/

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v5.0/contracts/utils/structs/EnumerableSet.sol";

contract Publisher is ERC721 {

    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    error OnlyOwnerCanAddNewVersion(bytes32 parentHash);
    error ParentHashHasNotBeenPublished(bytes32 parentHash);

    event ItemCreated(
        string _name,
        address indexed _creator,
        uint indexed _tokenId,
        bytes32 indexed _hash
    );

    struct Item {
        string name;
        string description;
        uint blockCreated;
        address creator;
        uint tokenId;
        bytes32 hash;
        bytes32 parentHash;
    }

    uint public counter = 1;
    mapping(uint => bytes32) public tokenIds;
    mapping(bytes32 => Item) public hashInfo;
    EnumerableSet.Bytes32Set internal allHashes;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    function createItem (
        string calldata _name,
        string calldata _description,
        bytes32 _hash,
        bytes32 _parentHash
    ) public {
    
        // only proceed if this file hash doesn't exist yet
        if (hashInfo[_hash].hash != _hash) {

            // ensure that the parent hash already exists in the registry
            if (_parentHash != bytes32(0) && hashInfo[_parentHash].hash == bytes32(0)) {
                revert ParentHashHasNotBeenPublished(_parentHash);
            }

            // ensure that only the owner of of the root file is allowed to version it
            if (_parentHash != bytes32(0) && ownerOf(hashInfo[_parentHash].tokenId) != msg.sender) {
                revert OnlyOwnerCanAddNewVersion(_parentHash);
            }

            Item memory _item = Item({
                name: _name,
                description: _description,
                blockCreated: block.number,
                creator: msg.sender,
                tokenId: counter,
                hash: _hash,
                parentHash: _parentHash
            });
            _mint(msg.sender, counter);
            allHashes.add(_hash);
            tokenIds[counter] = _hash;
            hashInfo[_hash] = _item;
            emit ItemCreated(_name, msg.sender, counter, _hash);
            counter++;
        }
    }

    function getItemByHash(bytes32 _hash) public view returns (Item memory) {
        return hashInfo[_hash];
    }

    function getAllHashes() public view returns (bytes32[] memory) {
        return allHashes.values();
    }
    
}