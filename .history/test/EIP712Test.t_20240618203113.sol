// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test,console} from "forge-std/Test.sol";
import {DeployVoting} from "../script/DeployVoting.s.sol";
import {Voting} from "../src/Voting.sol";

contract EIP712Test is Test {
    
    bytes32 constant VOTINGMESSAGE_TYPEHASH =
        keccak256("VotingMessage(uint256 poolId,uint256 contestantId,uint256 tickNumber,uint256 expriedTime)");

    bytes32 constant EIP712DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    EIP712Domain eip_712_domain_separator_struct;

    Voting public voting;
    address public USER1 = makeAddr("user1");

    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
    }

    struct VotingMessage {
        uint256 poolId;
        uint256 contestantId;
        uint256 tickNumber;
        uint256 expriedTime;
    }

    function setUp() external{
        DeployVoting deployVoting = new DeployVoting();
        voting = deployVoting.run();
        eip_712_domain_separator_struct = EIP712Domain({
            name: "VotingDapp",
            version: "1",
            chainId: 1,
            verifyingContract: address(voting)
        });
        
    }
    

}