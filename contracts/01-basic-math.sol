// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

contract BasicMath {

    function adder(uint _a, uint _b) external pure returns (uint, bool) {
        if (_b <= type(uint).max - _a) {
            return (_a + _b, false); 
        } else {
            return (0, true);
        }
    }

    function subtractor(uint _a, uint _b) external pure returns (uint, bool) {
        if (_a >= _b) {
            return (_a - _b, false); 
        } else {
            return (0, true);
        }
    }

}