

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";


contract Voting is Ownable {
    using ECDSA for bytes32;

    //errors

    constructor() Ownable(msg.sender) {
    }


    
}
