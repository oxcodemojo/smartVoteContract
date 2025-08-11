// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "../lib/forge-std/src/Script.sol";
import {SmartVote} from "../src/SmartVote.sol";

contract DeploySmartVote is Script {
    function run() public {
        vm.startBroadcast();
        string[] memory candidateNames = new string[](3);
        // candidateNames[0] = "ebby";
        // candidateNames[1] = "trump";
        // candidateNames[2] = "joe";
        // candidateNames[3] = "craig"; // intentional to check length
        new SmartVote(candidateNames);

        vm.stopBroadcast();
    }

    // contract address: 0x5FbDB2315678afecb367f032d93F642f64180aa3
}
