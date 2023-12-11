// SPDX-License-Identifier: UNLICENSED

// TODO
// NFT standard instead of ERC20
// token owner can version? and/or edit text descriptions?
// IPFS storage?

pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v5.0/contracts/utils/structs/EnumerableSet.sol";

contract Publisher is ERC721 {

    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    struct Item {
        string name;
        string description;
        uint blockCreated;
        address creator;
        bytes32 hash;
    }

    event ItemCreated(
        string indexed _name,
        address indexed _creator,
        bytes32 indexed _hash
    );

    mapping(bytes32 => Item) public hashInfo;
    mapping(address => bytes32[]) public hashListByCreator;
    EnumerableSet.AddressSet internal allCreators;
    EnumerableSet.Bytes32Set internal allHashes;


    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}


    function testHash () public pure returns (bytes32) {
        return keccak256(abi.encode([1,2,3]));
    }

    function testHash2 (bytes memory _input) public pure returns (bytes32) {
        return keccak256(_input);
    }


    function createItem (
        string calldata _name,
        string calldata _description,
        bytes32 _hash
    ) public returns (bytes32 itemHash, bool itemCreated) {
        if (hashInfo[_hash].hash != _hash) {
            allHashes.add(_hash);
            allCreators.add(msg.sender);
            hashListByCreator[msg.sender].push(_hash);
            Item memory _item = Item({
                name: _name,
                description: _description,
                blockCreated: block.number,
                creator: msg.sender,
                hash: _hash
            });

            //_mint(msg.sender, uint(_hash));
            // TODO: figure out to to map each token ID to a hash

            hashInfo[_hash] = _item;
            emit ItemCreated(_name, msg.sender, _hash);
            return (_hash, true);
        }
        return (_hash, false);
    }


    function getItemByHash(bytes32 _hash) public view returns (Item memory) {
        return hashInfo[_hash];
    }

    function getHashListByAddress(address _address) public view returns (bytes32[] memory) {
        return hashListByCreator[_address];
    }

    function getAllHashes() public view returns (bytes32[] memory) {
        return allHashes.values();
    }

    function getAllCreators() public view returns (address[] memory) {
        return allCreators.values();
    }

    function getItemsByCreator(address _creatorAddress) public view returns (Item[] memory) {
        bytes32[] memory _hashes = hashListByCreator[_creatorAddress];
        Item[] memory _items = new Item[](_hashes.length);
        for (uint i; i < _items.length; i++) {
            _items[i] = hashInfo[_hashes[i]];
        }
        return _items;
    }
    
}