// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract SmartVote is Ownable {
    /**
     * @dev devhat
     * @notice a smart contract for voting based on highest number of votes.
     * @dev implements openzeppelin Ownable contract
     */
    mapping(address => bool) public hasVoted;
    Candidate[] public candidates;
    bool public votingEnded;

    struct Candidate {
        string candidateName;
        uint256 candidateVoteCount;
    }

    // errors
    error SmartVote__InvalidCandidateId();
    error SmartVote__AlreadyVoted();
    error SmartVote__VotingAlreadyEnded();
    error SmartVote__VotingIsLive();

    // events
    event Voted(address indexed voter, bool voted, uint256 candidateId);
    event VotingEnded(uint256 winnerId);

    // constructor

    constructor(string[] memory _candidateNames) Ownable(msg.sender) {
        for (uint256 i; i < _candidateNames.length; i++) {
            candidates.push(Candidate(_candidateNames[i], 0));
        }
        // this provides a starting list of candidates for the elections.
        // all candidates begin with 0 votes
        // name and vote count
        // candidates = [1,2,3]
    }

    function vote(uint256 candidateId) public {
        if (candidateId < 0 || candidateId > candidates.length) {
            revert SmartVote__InvalidCandidateId();
        }
        if (hasVoted[msg.sender] == true) {
            revert SmartVote__AlreadyVoted();
        }
        if (votingEnded == true) {
            revert SmartVote__VotingAlreadyEnded();
        }
        hasVoted[msg.sender] = true;
        candidates[candidateId].candidateVoteCount++;

        emit Voted(msg.sender, true, candidateId);
    }

    function endVotingAndDeclareWinner() public onlyOwner {
        if (votingEnded) {
            revert SmartVote__VotingAlreadyEnded();
        }
        votingEnded = true;
        uint256 candidateIdOfWinner = 0;
        uint256 highestVoteCount = 0;

        for (uint256 i; i < candidates.length; i++) {
            if (candidates[i].candidateVoteCount > highestVoteCount) {
                highestVoteCount = candidates[i].candidateVoteCount;
                candidateIdOfWinner = i;
            }
        }

        emit VotingEnded(candidateIdOfWinner);
    }

    function getWinner() public view returns (string memory, uint256 votes) {
        // returns the details of the candidate with the highest number of votes...

        if (!votingEnded) {
            revert SmartVote__VotingIsLive();
        }
        uint256 IdOfWinningCandidate = 0;
        uint256 highestVoteCount = 0;

        for (uint256 i; i < candidates.length; i++) {
            if (candidates[i].candidateVoteCount > highestVoteCount) {
                highestVoteCount = candidates[i].candidateVoteCount;
                IdOfWinningCandidate = i;
            }
        }

        return (candidates[IdOfWinningCandidate].candidateName, highestVoteCount);
    }

    function getCandidate(uint256 id) public view returns (string memory _name, uint256 _voteCount) {
        if (id < 0 || id > candidates.length) {
            revert SmartVote__InvalidCandidateId();
        }
        Candidate memory _candidate = candidates[id];
        return (_candidate.candidateName, _candidate.candidateVoteCount);
    }

    function restartVoting() public onlyOwner returns (bool) {
        if (votingEnded == true) {
            votingEnded = false;
        }
        return votingEnded;
    }

    function getOwner() public view returns (address) {
        return owner();
    }

    function getVoteCount(uint256 candidateId) public view returns (uint256) {
        return candidates[candidateId].candidateVoteCount;
    }

    function getCandidateInfo(uint256 canId) public view returns (string memory, uint256) {
        return (candidates[canId].candidateName, candidates[canId].candidateVoteCount);
    }
}
