// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
//Deploy the Raffle contract

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {Raffle} from "../src/Raffle.sol";
import {AddConsumer, CreateSubscription, FundSubscription} from "./Interactions.s.sol";
import {CodeConstants} from "./HelperConfig.s.sol";

contract DeployRaffle is CodeConstants, Script {
    function run() external returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig(); // This comes with our mocks!
        AddConsumer addConsumer = new AddConsumer();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        if (config.subscriptionId == 0) {
            if (block.chainid == LOCAL_CHAIN_ID) {
                // Only auto-create subscription on local networks
                CreateSubscription createSubscription = new CreateSubscription();
                (config.subscriptionId, config.vrfCoordinatorV2_5) =
                    createSubscription.createSubscription(config.vrfCoordinatorV2_5, config.account);

                FundSubscription fundSubscription = new FundSubscription();
                fundSubscription.fundSubscription(
                    config.vrfCoordinatorV2_5, config.subscriptionId, config.link, config.account
                );

                helperConfig.setConfig(block.chainid, config);
            } else {
                revert("Subscription ID must be set in HelperConfig for real networks. Create one at https://vrf.chain.link/");
            }
        }

        vm.startBroadcast(config.account);
        Raffle raffle = new Raffle(
            config.subscriptionId,
            config.gasLane,
            config.automationUpdateInterval,
            config.raffleEntranceFee,
            config.callbackGasLimit,
            config.vrfCoordinatorV2_5
        );
        vm.stopBroadcast();

        // already have a broadcast in here
        addConsumer.addConsumer(address(raffle), config.vrfCoordinatorV2_5, config.subscriptionId, config.account);
        return (raffle, helperConfig);
    }
}