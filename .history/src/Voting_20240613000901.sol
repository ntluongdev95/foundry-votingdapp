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
    event PoolCreated(uint256 indexed poolId, string ipfs, uint256 startAt, uint256 endsAt, address creator);

    ///////////////////
    // Modifiers
    ///////////////////

    ///////////////////
    // Functions
    ///////////////////
    constructor() Ownable(msg.sender) {}

    function createPool(string memory _ipfs, uint256 _startAt, uint256 _endsAt) external {
        if (_startAt <= block.timestamp || _endsAt <= _startAt) {
            revert Voting_InvalidTimeRange();
        }
        if (bytes(name).length == 0 ||bytes(title).length == 0 ||bytes(description).length == 0){
            revert Voting_AllRequired();
        }
        s_totalPools += 1;
        s_pools[s_totalPools] = Pool({
            poolId: s_totalPools,
            ipfs: _ipfs,
            startAt: _startAt,
            endsAt: _endsAt,
            status: PoolStatus.Active,
            creator: msg.sender
        });
        emit PoolCreated(s_totalPools, _ipfs, _startAt, _endsAt, msg.sender);
    }
    function addContestant (Contestant[] calldata contestants) external {
        
    }
}
