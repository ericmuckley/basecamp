// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

contract UnburnableToken {

    error TokensClaimed();
    error AllTokensClaimed();
    error UnsafeTransfer(address _to);

    mapping(address => uint) public balances;
    mapping(address => uint) public claimedBalances;
    uint public totalSupply;
    uint public claimAmount;
    uint public totalClaimed;

    constructor() {
        totalSupply = 100000000;
        claimAmount = 1000;
    }

    // Add a public function called claim.
    // When called, so long as a number of tokens equaling the
    // totalSupply have not yet been distributed, any wallet that
    // has not made a claim previously should be able to claim 1000 tokens.
    // If a wallet tries to claim a second time, it should revert with TokensClaimed.
    function claim() public {

        if (claimedBalances[msg.sender] > 0) {
            revert TokensClaimed();
        }

        if (totalSupply - totalClaimed < claimAmount) {
            revert AllTokensClaimed();
        }

        balances[msg.sender] += claimAmount;
        claimedBalances[msg.sender] += claimAmount;
        totalClaimed += claimAmount;

    }

    function getEthBalance(address _address) public view returns (uint _balance) {
       return _address.balance;
    }

    // Implement a public function called safeTransfer that accepts an
    // address _to and an _amount. It should transfer tokens from the
    // sender to the _to address, only if:
    //    - That address is not the zero address
    //    - That address has a balance of greater than zero Base Goerli Eth
    // A failure of either of these checks should result in a revert with
    // an UnsafeTransfer error, containing the address.
    function safeTransfer(address _to, uint _amount) public {
        if (_to == address(0) || getEthBalance(_to) == 0) {
            revert UnsafeTransfer(_to);
        } else if (balances[msg.sender] >= _amount) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
        }
    }

}
