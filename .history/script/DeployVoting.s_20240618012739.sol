// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Script} from "forge-std/Script.sol";
import {Voting} from "../src/Voting.sol";

 contract DeployVoting is Script{
   
    function run() public returns (Voting){
       vm.startBroadcast();
       Voting voting = new Voting();
        vm.stopBroadcast();
        return deployer
    }

}
