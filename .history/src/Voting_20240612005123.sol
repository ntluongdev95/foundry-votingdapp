
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import{BitMaps} from "@openzeppelin/contracts/utils/structs/BitMaps.sol";


contract Voting is Ownable {

    ///////////////////
    // Errors
    ///////////////////


     ///////////////////
    // Types
    ///////////////////
    using ECDSA for bytes32;

     ///////////////////
    // State Variables
    ///////////////////
    uint256 private s_totalPools;
    uint256 private s_totalContestants;

    enum PoolStatus{
        Inactive,
        Active,
       
    }

    struct Contestant{
        uint256 contestantId;
        string  ipfs;   //all relative info of the contestant
        uint256 votesCount;
    }

    struct Pool{
        uint256 poolId;
        string  ipfs;   //all relative info of the pool
        Contestant[] contestants;
        uint256 startAt;
        uint256 endsAt;
        BitMaps.BitMap voted;
        PoolStatus status;
    }


     ///////////////////
    // Events
    
    ///////////////////

     ///////////////////
    // Modifiers
    ///////////////////


    ///////////////////
    // Functions
    ///////////////////
    constructor() Ownable(msg.sender) {
    }


    
}
