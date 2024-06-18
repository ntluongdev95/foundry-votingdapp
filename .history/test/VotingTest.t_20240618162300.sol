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

        vm.prank(address(1)); // Simulate a different user creating the pool
        vm.expectRevert("Voting_AllRequired()");
        voting.createPool(images, name, title, description, startAt, endsAt);
    }


}