// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC721/ERC721.sol";

contract HaikuNFT is ERC721{

    error HaikuNotUnique();
    error NoHaikusShared();
    error NotYourHaikuToShare();

    struct Haiku {
        address author;
        string line1;
        string line2;
        string line3;
    }

    Haiku[] public haikus;
    mapping(address => uint[]) public sharedHaikus;
    mapping(string => bool) public usedLines;
    uint public counter = 1;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {

    }

    // Add an external function called mintHaiku that takes in the three lines of the poem.
    // This function should mint an NFT for the minter and save their Haiku.
    // Haikus must be unique! If any line in the Haiku has been used as any
    // line of a previous Haiku, revert with HaikuNotUnique().
    function mintHaiku(
        string calldata _line1,
        string calldata _line2,
        string calldata _line3
    ) external {
        if (usedLines[_line1] || usedLines[_line2] || usedLines[_line3]) {
            revert HaikuNotUnique();
        } else {
            usedLines[_line1] = true;
            usedLines[_line2] = true;
            usedLines[_line3] = true;
            _mint(msg.sender, counter);
            Haiku memory _haiku = Haiku(msg.sender, _line1, _line2, _line3);
            haikus.push(_haiku);
            counter++;
        }
    }

    // Add a public function called shareHaiku that allows the owner of a
    // Haiku NFT to share that Haiku with the designated address they are sending it _to.
    // Doing so should add it to that address's entry in sharedHaikus.
    function shareHaiku(uint _id, address _to) public {
        //safeTransferFrom(msg.sender, _to, _id);
        //_transfer(msg.sender, _to, _id);
        if (ownerOf(_id) != msg.sender) {
            revert NotYourHaikuToShare();
        }
        sharedHaikus[_to].push(_id);
    }

    // Add a public function called getMySharedHaikus.
    // When called, it should return an array containing all of the haikus shared with the caller.
    // If there are no haikus shared with the caller's wallet,
    // it should revert with a custom error of NoHaikusShared, with no arguments.
    function getMySharedHaikus() public view returns (Haiku[] memory) {
        uint[] memory _myHaikuIds = sharedHaikus[msg.sender];
        if (_myHaikuIds.length == 0) {
            revert NoHaikusShared();
        }
        Haiku[] memory _mySharedHaikus = new Haiku[](_myHaikuIds.length);
        for (uint i; i < _mySharedHaikus.length; i++) {
            _mySharedHaikus[i] = haikus[_myHaikuIds[i]];
        }
        return _mySharedHaikus;
    }
}

