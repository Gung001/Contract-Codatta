// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import "../src/CodattaNFT.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract CodattaNFTDeploy is Script {

    function run() external {

        vm.startBroadcast();

        address OWNER_ADDRESS = 0xFc7CF39C030C391F4aC6638c367857DC18BbfE25;

        address uupsProxy = Upgrades.deployUUPSProxy(
            "CodattaNFT.sol",
            abi.encodeCall(CodattaNFT.initialize, (OWNER_ADDRESS, OWNER_ADDRESS))
        );

        console.log("uupsProxy deploy at %s", uupsProxy);

        vm.stopBroadcast();
    }
}