// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test,console} from "forge-std/Test.sol";
import {DeployVoting} from "../script/DeployVoting.s.sol";
import {Voting} from "../src/Voting.sol";

contract EIP712Test is Test {
    
    bytes32 constant VOTINGMESSAGE_TYPEHASH =
    keccak256("VotingMessage(uint256 poolId,uint256 contestantId,uint256 tickNumber,uint256 expriedTime)");
    

     Voting public voting;
    address public USER1 = makeAddr("user1");

    function setUp() external{
        DeployVoting deployVoting = new DeployVoting();
        voting = deployVoting.run();
        
    }
    function test_Ok () public {
       
    }

}