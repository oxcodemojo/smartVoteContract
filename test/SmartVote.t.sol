// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "../lib/forge-std/src/Test.sol";
import {SmartVote} from "../src/SmartVote.sol";
import {DeploySmartVote} from "../script/DeploySmartVote.s.sol";

contract TestSmartVote is Test {
    // Declare the event as in SmartVote
    event Voted(address indexed voter, bool success, uint256 candidateIndex);
    SmartVote smartVoteContract;
    address owner = address(0x1);
    address voter1 = address(0x2);
    address voter2 = address(0x3);
    address voter3 = address(0x4);
    address voter4 = address(0x5);
    address voter5 = address(0x6);

    function setUp() public {
        vm.prank(owner);
        string[] memory candidateNames = new string[](3);
        candidateNames[0] = "ebby";
        candidateNames[1] = "sally";
        candidateNames[2] = "peter";
        smartVoteContract = new SmartVote(candidateNames);
    }

    function test_deploy_smart_vote_contract() public {
        // ca on sepolia: 0xC6F9A8b2bD33bbf09563eA7fAFBaEf9bA6A5b9eA
        // i want to assert that the parameters on deployment are correct
        // i.e the string array of candidates contains:
        // 1. 3 candidates
        // 2. first candidate is "ebby"
        // 3. initial votecount of each candidate is 0 (nobody started with more than the other.)
        console.log(address(smartVoteContract));
        console.log(msg.sender);
        console.log(address(smartVoteContract.getOwner()));

        console.log(address(smartVoteContract.getOwner()));
    }

    function testVote() public {
        vm.prank(voter1);
        smartVoteContract.vote(0);
        (string memory name, uint256 voteCount) = smartVoteContract
            .getCandidate(0);
        assertEq(name, "ebby", "candidate's name should be ebby");
        assertEq(voteCount, 1, "vote count of ebby should be 1");
        console.log(address(this));
    }

    function testRestartVotingFailsIfNotOwner() public {
        vm.prank(voter1);
        vm.expectRevert();
       bool restartedVoting = smartVoteContract.restartVoting();
       assertTrue(!restartedVoting, "only owner can restart voting!");
       
    }

    function testRestartVotingPassIfOwner() public {
        address contractOwner = smartVoteContract.getOwner();
        vm.prank(contractOwner);
        smartVoteContract.endVotingAndDeclareWinner();

        vm.prank(contractOwner);
        bool restarted = smartVoteContract.restartVoting(); // true if voting has successfully restarted
        assertFalse(
            restarted,
            "restartVoting() should return true when called by owner"
        );
    }

    function testGetWinnerReturnsCandidateWithHigestVote() public {
        vm.prank(voter1);
        smartVoteContract.vote(0);

        vm.prank(voter2);
        smartVoteContract.vote(0);

        vm.prank(voter3);
        smartVoteContract.vote(1);

        vm.prank(voter4);
        smartVoteContract.vote(2);

        vm.prank(voter5);
        smartVoteContract.vote(0);

        // ca: 0x92609958A5AcCD6B9B4E27e422870dB3e532dd1b

        address contractOwner = smartVoteContract.getOwner();
        vm.prank(contractOwner);
        smartVoteContract.endVotingAndDeclareWinner();

        (string memory winnerName, uint256 voteCount) = smartVoteContract
            .getWinner();

        assertEq(winnerName, "ebby");
        assertEq(voteCount, 3);

        // vm.expectRevert(winnerName, "peter");
        // smartVoteContract.getWinner();
    }

    function testVotedEventEmittedOnVote() public {
        vm.startPrank(voter1);
        // Only the first parameter (voter) is indexed, so only first bool is true
        vm.expectEmit(true, false, false, true);
        emit Voted(voter1, true, 0);
        smartVoteContract.vote(0);
        vm.stopPrank();
    }

    function testRevertsIfVoterTriesToVoteMoreThanOnce() public {
        vm.prank(voter1);
        smartVoteContract.vote(0);

        vm.prank(voter1);
        vm.expectRevert();
        smartVoteContract.vote(0);

        uint256 voteCount = smartVoteContract.getVoteCount(0);
        assertEq(voteCount, 1);
    }

    function testGetCandidateInfo() public {
        vm.prank(voter1);
        smartVoteContract.vote(0);

        vm.prank(voter2);
        smartVoteContract.vote(0);

        (string memory name, uint256 votes) = smartVoteContract
            .getCandidateInfo(0);

        assertEq(name, "ebby", "candidate name is incorrect");
        assertEq(votes, 2, "candidate vote count is incorrect");

        console.log(name);
        console.log(votes);
    }

    //

    function testFullVotingFlow() public {
        // Add more voters
        address voter6 = address(0x7);
        address voter7 = address(0x8);
        address voter8 = address(0x9);
        address voter9 = address(0xA);
        address voter10 = address(0xB);

        // 5 votes for candidate 0
        vm.prank(voter1);
        smartVoteContract.vote(0);
        vm.prank(voter2);
        smartVoteContract.vote(0);
        vm.prank(voter3);
        smartVoteContract.vote(0);
        vm.prank(voter4);
        smartVoteContract.vote(0);
        vm.prank(voter5);
        smartVoteContract.vote(0);

        // 2 votes for candidate 1
        vm.prank(voter6);
        smartVoteContract.vote(1);
        vm.prank(voter7);
        smartVoteContract.vote(1);

        // 1 vote for candidate 2
        vm.prank(voter8);
        smartVoteContract.vote(2);

        // End voting and declare winner
        address contractOwner = smartVoteContract.getOwner();
        vm.prank(contractOwner);
        smartVoteContract.endVotingAndDeclareWinner();

        // Check winner
        (string memory winnerName, uint256 winnerVotes) = smartVoteContract
            .getWinner();
        assertEq(winnerName, "ebby", "Winner should be ebby");
        assertEq(winnerVotes, 5, "Winner should have 5 votes");

        // Log all candidates and their votes
        for (uint256 i = 0; i < 3; i++) {
            (string memory name, uint256 votes) = smartVoteContract
                .getCandidateInfo(i);
            console.log(
                string.concat(
                    "Candidate ",
                    vm.toString(i),
                    ": ",
                    name,
                    ", Votes: ",
                    vm.toString(votes)
                )
            );
        }
    }
}
