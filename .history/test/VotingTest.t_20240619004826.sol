// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test,console} from "forge-std/Test.sol";
import {DeployVoting} from "../script/DeployVoting.s.sol";
import {Voting} from "../src/Voting.sol";

contract VotingTest is Test{

    Voting public voting;
    address public USER1 = makeAddr("user1");
    address public user_2;
    uint256 internal ownerPrivateKey;

    function setUp() external{
        DeployVoting deployVoting = new DeployVoting();
        voting = deployVoting.run();
        ownerPrivateKey = 0xA11CE;
        user_2 = vm.addr(ownerPrivateKey);
        
        
    }
    function test_RevertInvalidTimeRange() public{
        string[] memory images = new string[](2);
        images[0] = "image1.jpg";
        images[1] = "image2.jpg";
        string memory name = "Pool Name";
        string memory title = "Pool Title";
        string memory description = "Pool Description";
        uint256 startAt = block.timestamp + 3600; // 1 hour from now
        uint256 endsAt = block.timestamp + 1800;  // 30 minutes from now (invalid)
        vm.startPrank(USER1);
        vm.expectRevert(Voting.Voting_InvalidTimeRange.selector);
        voting.createPool(images, name, title, description, startAt, endsAt);
      }
      function test_RevertAllRequired() public {
        string[] memory images = new string[](2);
        images[0] = "image1.jpg";
        images[1] = "image2.jpg";
        string memory name = ""; // Missing name
        string memory title = "Pool Title";
        string memory description = "Pool Description";
        uint256 startAt = block.timestamp + 3600; // 1 hour from now
        uint256 endsAt = block.timestamp + 7200;  // 2 hours from now

        vm.prank(address(USER1)); // Simulate a different user creating the pool
        vm.expectRevert(Voting.Voting_AllRequired.selector);
        voting.createPool(images, name, title, description, startAt, endsAt);
    }

    function test_CreatePoolSuccessfully() public{
        string[] memory images = new string[](2);
        images[0] = "image1.jpg";
        images[1] = "image2.jpg";
        string memory name = "Pool Name";
        string memory title = "Pool Title";
        string memory description = "Pool Description";
        uint256 startAt = block.timestamp + 3600; // 1 hour from now
        uint256 endsAt = block.timestamp + 7200;  // 2 hours from now
        vm.prank(address(USER1));
        voting.createPool(images, name, title, description, startAt, endsAt);
        Voting.Pool memory createdPool = voting.getPool(1);

        // Check that the pool details are correct
        assertEq(createdPool.name, name);
        assertEq(createdPool.title, title);
        assertEq(createdPool.description, description);
        assertEq(createdPool.startAt, startAt);
        assertEq(createdPool.endsAt, endsAt);
        assertEq(createdPool.creator, address(USER1));
        assertEq(createdPool.isDeleted,false);
    }
    function test_UpdatePoolSuccessfully() public {
        string[] memory images = new string[](2);
        images[0] = "image1.jpg";
        images[1] = "image2.jpg";
        string memory name = "Pool Name";
        string memory title = "Pool Title";
        string memory description = "Pool Description";
        uint256 startAt = block.timestamp + 3600; // 1 hour from now
        uint256 endsAt = block.timestamp + 7200;  // 2 hours from now
        vm.startPrank(address(USER1));
        voting.createPool(images, name, title, description, startAt, endsAt);
        vm.stopPrank();

        vm.startPrank(address(USER1)); // Ensure msg.sender is the pool creator
        voting.updatePool(1, "newUpdated",images, startAt, endsAt);
        Voting.Pool memory updatedPool = voting.getPool(1);
         vm.stopPrank();
        assertEq(updatedPool.name,"newUpdated"); 

        vm.startPrank(address(0x1234)); // Simulate a different user
        vm.expectRevert(Voting.Voting_NotOwner.selector);
        voting.updatePool(1, "newName", images, startAt, endsAt);
        vm.stopPrank();

        vm.startPrank(address(USER1));
        vm.expectRevert(Voting.Voting_PollNotFound.selector);
        voting.updatePool(2, "newName", images, startAt, endsAt);
        vm.stopPrank();
        
        vm.startPrank(address(USER1));
         vm.warp(block.timestamp + 3700);
        vm.expectRevert(Voting.Voting_PoolHasVoted.selector);
        voting.updatePool(1, "newName", images, startAt, endsAt);
        vm.stopPrank();

        // vm.startPrank(address(USER1));
        // vm.warp(block.timestamp + 7300);
        // vm.expectRevert(Voting.Voting_PoolHasEnded.selector);
        // voting.updatePool(1, "newName", images, startAt, endsAt);
        // vm.stopPrank();

        // vm.startPrank(address(USER1));
        // voting.deletePool(1);
        // vm.expectRevert(Voting.Voting_PoolHasDeleted.selector);
        // voting.updatePool(1, "newName", images, startAt, endsAt);
        //  vm.stopPrank();
    }

    function test_CreateContestantSuccesfully() public {
        string[] memory images = new string[](2);
        images[0] = "image1.jpg";
        images[1] = "image2.jpg";
        string memory name = "Pool Name";
        string memory title = "Pool Title";
        string memory description = "Pool Description";
        uint256 startAt = block.timestamp + 3600; // 1 hour from now
        uint256 endsAt = block.timestamp + 7200;  // 2 hours from now
        vm.startPrank(address(USER1));
        voting.createPool(images, name, title, description, startAt, endsAt);
        vm.stopPrank();

        vm.startPrank(address(USER1));
        voting.addContestant(1, "Contestant Name", "contestant.jpg");
        vm.stopPrank();
        // Check if contestant was added successfully
        Voting.Contestant[] memory contestants = voting.getContestants(1);
        assertEq(contestants.length, 1);
        assertEq(contestants[0].name, "Contestant Name");
        assertEq(contestants[0].image, "contestant.jpg");
        assertEq(contestants[0].votesCount, 0);
        assertEq(contestants[0].contestantId,1);
    }

    function test_VoteSuccessfully() public {
        string[] memory images = new string[](2);
        images[0] = "image1.jpg";
        images[1] = "image2.jpg";
        string memory name = "Pool Name";
        string memory title = "Pool Title";
        string memory description = "Pool Description";
        uint256 startAt = block.timestamp + 3600; // 1 hour from now
        uint256 endsAt = block.timestamp + 7200;  // 2 hours from now
        vm.startPrank(address(USER1));
        voting.createPool(images, name, title, description, startAt, endsAt);
        voting.addContestant(1, "Contestant Name", "contestant.jpg");

        vm.stopPrank();
        Voting.Pool memory createdPool = voting.getPool(1);
        Voting.Contestant[] memory contestants = voting.getContestants(1);
        assertEq(contestants[0].votesCount, 0);
        Voting.VotingMessage memory voteMsg = Voting.VotingMessage({
            poolId: createdPool.poolId,
            contestantId: 1,
            tickNumber: 1,
            expriedTime: block.timestamp + 1 hours
        });

        bytes32 messageHash = voting.getVotingMessageHash(voteMsg);
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                voting.i_domain_separator(),
                messageHash
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);
        vm.warp( block.timestamp + 3)
        vm.startPrank(user_2);
        voting.vote(voteMsg, signature, user_2);
        vm.stopPrank();
        // Voting.Contestant[] memory contestants = voting.getContestants(1);
        // assertEq(contestants[0].votesCount, 1);
    }








}