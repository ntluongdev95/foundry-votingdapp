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
    error Voting_PoolHasVoted();
    error Voting_PoolHasEnded();
    error Voting_PoolHasDeleted();


    ///////////////////
    // Types
    ///////////////////
    using ECDSA for bytes32;

    ///////////////////
    // State Variables
    ///////////////////
    uint256 private s_totalPools =0;
    uint256 private s_totalContestants = 0;
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
        bool isDeleted;
    }

    ///////////////////
    // Events
    ///////////////////
    event PoolCreated(uint256 indexed poolId, uint256 startAt, uint256 endsAt, address creator);
    event ContestantAdded(uint256 indexed poolId, uint256 indexed contestantId);
    event PoolUpdated(uint256 indexed poolId, address creator);
    event DeletePool(uint256 indexed poolId, address deletedBy);
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
            contestants:0,
            startAt: _startAt,
            endsAt: _endsAt,
            status: PoolStatus.Active,
            creator: msg.sender,
            isDeleted: false
        });
        emit PoolCreated(s_totalPools, _startAt, _endsAt, msg.sender);
    }
    function updatePool(uint256 poolId,string memory name,string memory image,uint256 startAt,uint256 endsAt)external{
        if(poolId > s_totalPools){
            revert Voting_PollNotFound();
        }
        Poll storage pool = s_pools[poolId];
        if(pool.isDeleted){
            revert Voting_PoolHasDeleted();
        }
        onlyOwner(pool.creator);
        checkTime(pool.startAt);
        pool.startAt = startAt;
        pool.endsAt = endsAt;
        pool.name = name;
        pool.image = image;

       emit PoolUpdated(poolId, msg.sender);
    }
    function deletePoll()
    function addContestant (uint256 poolId,string memory name,string memory image) external {
        if(poolId > s_totalPools){
            revert Voting_PollNotFound();
        }
        Poll storage pool = s_pools[poolId];
         if(pool.isDeleted){
            revert Voting_PoolHasDeleted();
        }
        onlyOwner(pool.creator);
        checkTime(pool.startAt);
         if(bytes(name).length == 0 || bytes(image).length == 0){
            revert Voting_AllRequired();
        }
        s_totalContestants += 1;
        s_contestants[poolId][s_totalContestants] = Contestant({
            contestantId: s_totalContestants,
            name: name,
            image: image,
            votesCount: 0
        });
        pool.contestants += 1;
        emit ContestantAdded(poolId, s_totalContestants);
    }

    //View functions
    function getPool(uint256 poolId) external view returns (Pool memory) {
        return s_pools[poolId];
    }

    function onlyOwner(address owner) internal {
        if(owner != msg.sender){
            revert Voting_NotOwner();
        }
    }
    function checkTime(uint256 startingTime,uint256 endingTime) internal{
        if(startingTime <= block.timestamp){
            revert Voting_PoolHasStarted();
        }
        if(endingTime <= block.timestamp){
            revert Voting_PoolHasEnded();
        }

    }
}
