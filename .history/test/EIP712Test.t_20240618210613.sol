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
    address public user_1;
    uint256 internal ownerPrivateKey;


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
        ownerPrivateKey = 0xA11CE;
        user_1 = vm.addr(ownerPrivateKey);
        
    }
    function test_DomainSeparator() public view {
        bytes32 expectedDomainSeparator = keccak256(
            abi.encode(
                EIP712DOMAIN_TYPEHASH,
                keccak256(bytes(eip_712_domain_separator_struct.name)),
                keccak256(bytes(eip_712_domain_separator_struct.version)),
                eip_712_domain_separator_struct.chainId,
                eip_712_domain_separator_struct.verifyingContract
            )
        );
        assertEq(voting.i_domain_separator(), expectedDomainSeparator, "Domain separator mismatch");
    }

    function test_VotingMessageHash() public view {
         Voting.VotingMessage memory voteMsg = Voting.VotingMessage({
            poolId: 1,
            contestantId: 1,
            tickNumber: 12345,
            expriedTime: block.timestamp + 1 hours
        });

        bytes32 expectedMessageHash = keccak256(
            abi.encode(
                VOTINGMESSAGE_TYPEHASH,
                1,1,12345,block.timestamp + 1 hours
            )
        );
        bytes32 actualMessageHash = voting.getVotingMessageHash(voteMsg);
        assertEq(actualMessageHash, expectedMessageHash, "Voting message hash mismatch");
    }

    function testSplitSignature() public view {
        // Simulating signing a hash
        bytes32 messageHash = keccak256(abi.encodePacked("Test message"));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, messageHash);

        // Construct the signature from r, s, and v
        bytes memory signature = abi.encodePacked(r, s, v);

        // Split the signature using the contract function
        (bytes32 rRecovered, bytes32 sRecovered, uint8 vRecovered) = voting.splitSignature(signature);

        // Verify that the components match
        assertEq(rRecovered, r, "Recovered r does not match");
        assertEq(sRecovered, s, "Recovered s does not match");
        assertEq(vRecovered, v, "Recovered v does not match");
    }

    function testGetSignerEIP712() public {
        Voting.VotingMessage memory voteMsg = VotingMessage({
            poolId: 1,
            contestantId: 1,
            tickNumber: 12345,
            expriedTime: block.timestamp + 1 hours
        });

        bytes32 messageHash = voting.getVotingMessageHash(voteMsg);

        // Simulating signing the message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(address(this).privateKey, messageHash);

        // Construct the signature from r, s, and v
        bytes memory signature = abi.encodePacked(r, s, v);

        // Recover the signer address
        address recoveredAddress = voting.getSignerEIP712(voteMsg, signature);
        assertEq(recoveredAddress, address(this), "Recovered address does not match the signer");
    }

}