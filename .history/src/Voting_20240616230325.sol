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
    bytes32 constant VOTINGMESSAGE_TYPEHASH = 
          keccak256("VotingMessage(uint256 poolId,uint256 contestantId,uint256 tickNumber,uint256 expriedTime)");
    bytes32 constant EIP712DOMAIN_TYPEHASH =
	      keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    EIP712Domain eip_712_domain_separator_struct = EIP712Domain({
	name: "VotingDapp", // this can be anything
	version: "1", // this can be anything
	chainId: 1, // ideally the chainId
	verifyingContract: address(this) 
    });
    bytes32 public immutable i_domain_separator = keccak256(
	abi.encode(
		EIP712DOMAIN_TYPEHASH,
		keccak256(bytes(eip_712_domain_separator_struct.name)),
		keccak256(bytes(eip_712_domain_separator_struct.version)),
		eip_712_domain_separator_struct.chainId,
		eip_712_domain_separator_struct.verifyingContract
	)
   );
    
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

    struct VotingMessage{
        uint256 poolId;
        uint256 contestantId;
        uint256 tickNumber;
        uint256 expriedTime;
    }
    struct EIP712Domain {	
	string name;
	string version;
	uint256 chainId;
	address verifyingContract;
	
    }

    struct Contestant {
        uint256 contestantId;
        string name;
        string image;
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
    function deletePoll(uint256 poolId) external {
        if(poolId > s_totalPools){
            revert Voting_PollNotFound();
        }
        Poll storage pool = s_pools[poolId];
        if(pool.isDeleted){
            revert Voting_PoolHasDeleted();
        }
        if(msg.sender != owner()|| msg.sender != s_pools[poolId].creator){
            revert Voting_NotOwner();
        }
        delete s_pools[poolId];
         emit DeletePool(poolId, msg.sender);
    }
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

    function vote (uint256 poolId, uint256 contestantId, bytes memory signature) external {
        if(poolId > s_totalPools){
            revert Voting_PollNotFound();
        }
        Poll storage pool = s_pools[poolId];
        if(pool.isDeleted){
            revert Voting_PoolHasDeleted();
        }
        checkTime(pool.startAt,pool.endsAt);
        if(s_voted[poolId].get(contestantId)){
            revert Voting_PoolHasVoted();
        }
        bytes32 message = abi.encodePacked(poolId, contestantId);
        address signer = message.toEthSignedMessageHash().recover(signature);
        if(signer != owner()){
            revert Voting_NotOwner();
        }
        s_voted[poolId].set(contestantId);
        s_contestants[poolId][contestantId].votesCount += 1;
    }

    //View functions

    
    function getPool(uint256 poolId) public view returns (Pool memory) {
        return s_pools[poolId];
    }
  
    function getAllPools() public view returns (Pool[] memory) {
        uint256 totalPools = s_totalPools;
        uint256 activePools ;
        for(uint256 i=1; i <= totalPools;){
            if(!s_pools[i].isDeleted){
                activePools += 1;
            }
            unchecked {
                ++i;
            }
        }
        Poll[] memory pools = new Poll[](activePools);
        uint256 index = 0;
        for(uint256 i=1; i <= totalPools;){
            if(!s_pools[i].isDeleted){
                pools[index] = s_pools[i];
                index += 1;
            }
            unchecked {
                ++i;
            }
        }
        return pools;
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
