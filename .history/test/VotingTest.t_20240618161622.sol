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
        uint256 releaseTime  = wm.warp
        console.log(vm.warp(releaseTime));
    }
    function test_RevertInvalidTimeRange() public{
        // vm.startPrank(USER1);
        // vm.expectRevert(Voting.Voting_InvalidTimeRange.selector);
        // voting.createPool(["url1"],"name","title","description",vm.warp(block.timestamp),vm.warp(block.timestamp + 5));
      }


}