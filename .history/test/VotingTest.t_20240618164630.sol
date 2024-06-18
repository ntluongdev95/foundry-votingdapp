// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test,console} from "forge-std/Test.sol";
import {DeployVoting} from "../script/DeployVoting.s.sol";
import {Voting} from "../src/Voting.sol";

contract VotingTest is Test{

    Voting public voting;
    address public USER1 = makeAddr("user1");

    function setUp() external{
        DeployVoting deployVoting = new DeployVoting();
        voting = deployVoting.run();
        
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
    function testUpdatePoolSuccessfully() public {
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
        vm.stop
        vm.prank(address(this)); // Ensure msg.sender is the pool creator
        voting.updatePool(1, newName, newImages, newStartAt, newEndsAt);

        Voting.Pool memory updatedPool = voting.getPool(1);
        assertEq(updatedPool.name, newName);
        assertEq(updatedPool.startAt, newStartAt);
        assertEq(updatedPool.endsAt, newEndsAt);
        assertEq(updatedPool.images[0], newImages[0]);
        assertEq(updatedPool.images[1], newImages[1]);
    }




}