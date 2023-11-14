// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

// Create a contract called ImportsExercise. It should import a copy of SillyStringUtils
import "./8-imports_lib.sol";

contract ImportsExercise {

    // Add a public instance of Haiku called haiku.
    using SillyStringUtils for SillyStringUtils.Haiku;
    SillyStringUtils.Haiku public haiku;

    // saveHaiku should accept three strings and save them as the lines of haiku.
    function saveHaiku(string calldata _string1, string calldata _string2, string calldata _string3) public {
        haiku.line1 = _string1;
        haiku.line2 = _string2;
        haiku.line3 = _string3;
    }
    // getHaiku should return the haiku as a Haiku type.
    function getHaiku() public view returns (SillyStringUtils.Haiku memory) {
        return haiku;
    }
    // shruggieHaiku should use the library to add 🤷 to the end of line3.
    // It must not modify the original haiku.
    function shruggieHaiku() public view returns (SillyStringUtils.Haiku memory) {
        SillyStringUtils.Haiku memory _sHaiku = SillyStringUtils.Haiku({
            line1: haiku.line1,
            line2: haiku.line2,
            line3: SillyStringUtils.shruggie(haiku.line3)
        });
        return _sHaiku;
    }
}