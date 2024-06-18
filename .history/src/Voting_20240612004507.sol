
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

    struct Pool{
        uint256 poolId;
        string  ipfs;//all relative info 

        BitMaps.BitMap voted;




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
