// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {BitMaps} from "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";

contract Voting is AutomationCompatibleInterface, Ownable {
    ///////////////////
    // Errors
    ///////////////////
    error Voting_InvalidTimeRange();
    error Voting_AllRequired();
    error Voting_PollNotFound();
    error Voting_NotOwner();

    ///////////////////
    // Types
    ///////////////////
    using ECDSA for bytes32;

    ///////////////////
    // State Variables
    ///////////////////
    uint256 private s_totalPools;
    uint256 private s_totalContestants;
    mapping(uint256 => Pool) private s_pools;
    mapping(uint256 => mapping(uint256 => Contestant)) private s_contestants;
    mapping(uint256 => BitMaps.BitMap) private s_voted;
    mapping(uint256 =>Contestant) public s_winner;

    enum PoolStatus {
        Active,
        Paused
    }

    struct Contestant {
        uint256 contestantId;
        string ipfs; //all relative info of the contestant
        uint256 votesCount;
    }

    struct Pool {
        uint256 poolId;
        string[] images;
        string title;
        string description;
        uint256 contestants; 
        uint256 startAt;
        uint256 endsAt;
        PoolStatus status;
        address creator;
    }

    ///////////////////
    // Events
    ///////////////////
    event PoolCreated(uint256 indexed poolId, uint256 startAt, uint256 endsAt, address creator);

    ///////////////////
    // Modifiers
    ///////////////////
    modifier _onlyPoolOwner(address owner) {
        require(owner == msg.sender, "Only pool owner can perform this action");
        _;
    }
     

    ///////////////////
    // Functions
    ///////////////////
    constructor() Ownable(msg.sender) {}

    function createPool(string memory _name,string memory _title,string memory _description, uint256 _startAt, uint256 _endsAt) external {
        if (_startAt <= block.timestamp || _endsAt <= _startAt) {
            revert Voting_InvalidTimeRange();
        }
        if (bytes(_name).length == 0 ||bytes(_title).length == 0 ||bytes(_description).length == 0){
            revert Voting_AllRequired();
        }
        s_totalPools += 1;
        s_pools[s_totalPools] = Pool({
            poolId: s_totalPools,
            name:_name,
            title :_title,
            description: _description,
            startAt: _startAt,
            endsAt: _endsAt,
            status: PoolStatus.Active,
            creator: msg.sender
        });
        emit PoolCreated(s_totalPools, _startAt, _endsAt, msg.sender);
    }
    function addContestant (uint256 poolId,Contestant[] calldata contestants) external {
        if(poolId > s_totalPools){
            revert Voting_PollNotFound();
        }
        if(contestants.length == 0 ||){
            revert Voting_AllRequired();
        }
        Poll storage pool = s_pools[poolId];
        onlyOwner(pool.creator);




    }

    function onlyOwner(address owner) internal {
        if(owner != msg.sender){
            revert Voting_NotOwner();
        }

    }
}
