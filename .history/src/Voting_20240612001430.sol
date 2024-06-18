
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";


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
    uint256 private totalPools;
    uint256 private totalContestants;
    struct Pool{
        uint256 poolId;
        string  poolNmae


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
