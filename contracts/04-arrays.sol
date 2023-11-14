// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

contract ArraysExercise {

    uint[] public numbers = [1,2,3,4,5,6,7,8,9,10];
    address[] public senders;
    uint[] public timestamps;

    //Write a function called getNumbers that returns the entire numbers array.
    function getNumbers() public view returns (uint[] memory){
        return numbers;
    }

    // Write a public function called resetNumbers that resets the numbers
    // array to its initial value, holding the numbers from 1-10.
    function resetNumbers() public {
        numbers = [1,2,3,4,5,6,7,8,9,10];
    }

    // Write a function called appendToNumbers that takes a
    // uint[] calldata array called _toAppend,
    // and adds that array to the storage array called numbers,
    // already present in the starter.
    function appendToNumbers(uint[] calldata _toAppend) public {
        for (uint i = 0; i < _toAppend.length; i++) {
            numbers.push(_toAppend[i]);
        }
    }


    // Write a function called saveTimestamp that takes a
    // uint called _unixTimestamp as an argument.
    // When called, it should add the address of the caller
    // to the end of senders and the _unixTimeStamp to timestamps.
    function saveTimestamp(uint _unixTimestamp) public {
        senders.push(msg.sender);
        timestamps.push(_unixTimestamp);
    }




    // Write a function called afterY2K that takes no arguments.
    // When called, it should return two arrays.
    // The first should return all timestamps that are more recent
    // than January 1, 2000, 12:00am. To save you a click,
    // the Unix timestamp for this date and time is 946702800.
    // The second should return a list of senders addresses corresponding to those timestamps.
    function afterY2K() public view returns(uint[] memory, address[] memory) {
        // loop once to get number of entries
        uint numberOfEntries;
        for (uint i = 0; i < timestamps.length && i < senders.length; i++) {
            if (timestamps[i] > 946702800) {
                numberOfEntries += 1;
            }
        }
        // save entries to arrays
        uint[] memory _afterTimestamps = new uint[](numberOfEntries);
        address[] memory _afterSenders = new address[](numberOfEntries);
        uint cursor = 0;
        for (uint i = 0; i < timestamps.length && i < senders.length; i++) {
            if (timestamps[i] > 946702800) {
                _afterTimestamps[cursor] = timestamps[i];
                _afterSenders[cursor] = senders[i];
                cursor ++;
            }
        }
        return (_afterTimestamps, _afterSenders);
    }


    function viewArrays() public view returns (uint[] memory, address[] memory){
        return (timestamps, senders);
    }


    // Add public functions called resetSenders and resetTimestamps
    // that reset those storage variables.
    function resetSenders() public {
        delete senders;
    }

    function resetTimestamps() public {
        delete timestamps;
    }

}