// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test,console} from "forge-std/Test.sol";

contract EIP712Test is Test {
    
     bytes32 constant VOTINGMESSAGE_TYPEHASH =
        keccak256("VotingMessage(uint256 poolId,uint256 contestantId,uint256 tickNumber,uint256 expriedTime)");
        console.log(VOTINGMESSAGE_TYPEHASH);

    function setUp() external {

    }
    function test_Ok () public {
       
    }

}