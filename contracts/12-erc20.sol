// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/utils/structs/EnumerableSet.sol";

contract WeightedVoting is ERC20 {
    
    using EnumerableSet for EnumerableSet.AddressSet;

    error TokensClaimed();
    error AllTokensClaimed();
    error NoTokensHeld();
    error QuorumTooHigh();
    error AlreadyVoted();
    error VotingClosed();

    struct Issue {
        EnumerableSet.AddressSet voters;
        string issueDesc;
        uint quorum;
        uint totalVotes;
        uint votesFor;
        uint votesAgainst;
        uint votesAbstain;
        bool passed;
        bool closed;
    }
    struct SerializedIssue {
        address[] voters;
        string issueDesc;
        uint quorum;
        uint totalVotes;
        uint votesFor;
        uint votesAgainst;
        uint votesAbstain;
        bool passed;
        bool closed;
    }

    enum Vote { AGAINST, FOR, ABSTAIN }
    Issue[] internal issues;
    mapping(address => bool) public tokensClaimed;
    uint public maxSupply = 1000000;
    uint public claimAmount = 100;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {
        issues.push();
    }

    // Add a public function called claim.
    // When called, so long as a number of tokens equalling the maximumSupply
    // have not yet been distributed, any wallet that has not made a claim previously
    // should be able to claim 100 tokens. If a wallet tries to claim a second time,
    // it should revert with TokensClaimed.
    // Once all tokens have been claimed, this function should revert with an error AllTokensClaimed.
    function claim() public {
        if (totalSupply() + claimAmount > maxSupply) {
            revert AllTokensClaimed();
        }
        if (tokensClaimed[msg.sender]) {
            revert TokensClaimed();
        } 
        _mint(msg.sender, claimAmount);
        tokensClaimed[msg.sender] = true;
    }

    // Implement an external function called createIssue.
    // It should add a new Issue to issues, allowing the user to set
    // the description of the issue, and quorum - which is how many
    // votes are needed to close the issue.
    // Only token holders are allowed to create issues, and issues cannot
    // be created that require a quorum greater than the current total number of tokens.
    // This function must return the index of the newly-created issue.
    function createIssue(string calldata _issueDesc, uint _quorum) external returns (uint) {
        if (balanceOf(msg.sender) == 0) {
            revert NoTokensHeld();
        }        
        if (_quorum > totalSupply()) {
            revert QuorumTooHigh();
        }
        Issue storage _issue = issues.push();
        _issue.issueDesc = _issueDesc;
        _issue.quorum = _quorum;    
        return issues.length - 1;
    }

    // Add an external function called getIssue that can return all
    // of the data for the issue of the provided _id.
    // EnumerableSet has a mapping underneath, so it can't be returned
    // outside of the contract. You'll have to figure something else out.
    function getIssue(uint _issueId) external view returns (SerializedIssue memory) {
        Issue storage _issue = issues[_issueId];
        return SerializedIssue({
            voters: _issue.voters.values(),
            issueDesc: _issue.issueDesc,
            quorum: _issue.quorum,
            totalVotes: _issue.totalVotes,
            votesFor: _issue.votesFor,
            votesAgainst: _issue.votesAgainst,
            votesAbstain: _issue.votesAbstain,
            passed: _issue.passed,
            closed: _issue.closed
        });
    }

    // Add a public function called vote that accepts an _issueId and the token holder's vote.
    // The function should revert if the issue is closed, or the wallet has already voted on this issue.
    // Holders must vote all of their tokens for, against, or abstaining from the issue.
    // This amount should be added to the appropriate member of the issue and the total
    // number of votes collected.
    // If this vote takes the total number of votes to or above the quorum for that vote, then:
    //  - The issue should be set so that closed is true
    //  - If there are more votes for than against, set passed to true
    function vote(uint _issueId, Vote _vote) public {
        Issue storage _issue = issues[_issueId];

        if (_issue.closed) {
            revert VotingClosed();
        }
        if (_issue.voters.contains(msg.sender)) {
            revert AlreadyVoted();
        }

        uint nTokens = balanceOf(msg.sender);      
        if (nTokens == 0) {
            revert NoTokensHeld();
        }

        if (_vote == Vote.AGAINST) {
            _issue.votesAgainst += nTokens;
        } else if (_vote == Vote.FOR) {
            _issue.votesFor += nTokens;
        } else {
            _issue.votesAbstain += nTokens;
        }

        _issue.voters.add(msg.sender);
        _issue.totalVotes += nTokens;

        if (_issue.totalVotes >= _issue.quorum) {
            _issue.closed = true;
            if (_issue.votesFor > _issue.votesAgainst) {
                _issue.passed = true;
            }
        }
    }

}