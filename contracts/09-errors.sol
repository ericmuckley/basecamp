// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract ErrorTriageExercise {
    /**
     * Finds the difference between each uint with it's neighbor (a to b, b to c, etc.)
     * and returns a uint array with the absolute integer difference of each pairing.
     */
    function diffWithNeighbor(
        uint _a,
        uint _b,
        uint _c,
        uint _d
    ) public pure returns (uint[] memory) {
        uint[] memory results = new uint[](3);
        results[0] = _absoluteDifference(_a, _b);
        results[1] = _absoluteDifference(_b, _c);
        results[2] = _absoluteDifference(_c, _d);
        return results;
    }

    function _absoluteDifference(uint _a, uint _b) internal pure returns (uint) {
        if (_a >= _b) {
            return _a - _b;
        } else {
            return _b - _a;
        }
    }

    /**
     * Changes the _base by the value of _modifier.  Base is always > 1000.  Modifiers can be
     * between positive and negative 100;
     */
    function applyModifier(
        uint _base,
        int _modifier
    ) public pure returns (int) {
        return int(_base) + _modifier;
    }

    /**
     * Pop the last element from the supplied array, and return the modified array and the popped
     * value (unlike the built-in function)
     */
    uint[] arr;

    function popWithReturn() public returns (uint) {
        uint index = arr.length - 1;
        uint _poppedElement = arr[index];
        //delete arr[index];
        arr.pop();
        return _poppedElement;
    }

    // The utility functions below are working as expected
    function addToArr(uint _num) public {
        arr.push(_num);
    }

    function getArr() public view returns (uint[] memory) {
        return arr;
    }

    function resetArr() public {
        delete arr;
    }
}
