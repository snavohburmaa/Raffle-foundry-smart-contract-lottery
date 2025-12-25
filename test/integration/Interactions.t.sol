// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "../../script/Interactions.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {Raffle} from "../../src/Raffle.sol";
import {CodeConstants} from "../../script/HelperConfig.s.sol";

contract InteractionsTest is Test, CodeConstants {
    HelperConfig public helperConfig;
    HelperConfig.NetworkConfig public config;
    VRFCoordinatorV2_5Mock public vrfCoordinator;
    Raffle public raffle;

    function setUp() public {
        helperConfig = new HelperConfig();
        config = helperConfig.getConfig();
        vrfCoordinator = VRFCoordinatorV2_5Mock(config.vrfCoordinatorV2_5);

        raffle = new Raffle(
            config.subscriptionId,
            config.gasLane,
            config.automationUpdateInterval,
            config.raffleEntranceFee,
            config.callbackGasLimit,
            config.vrfCoordinatorV2_5
        );
    }

    //Create Subscription Test

    function testCreateSubscriptionWorks() public {
        // Arrange
        CreateSubscription createSub = new CreateSubscription();

        // Act
        (uint256 subId, address vrfAddress) = createSub.createSubscription(
            config.vrfCoordinatorV2_5,
            config.account
        );

        // Assert
        assert(subId > 0);
        assertEq(vrfAddress, config.vrfCoordinatorV2_5);
    }

   //Fund Subscription Test

    function testFundSubscriptionIncreasesBalance() public {
        // Arrange
        vm.startBroadcast(config.account);
        uint256 subId = vrfCoordinator.createSubscription();
        vm.stopBroadcast();

        FundSubscription fundSub = new FundSubscription();

        // Act
        fundSub.fundSubscription(
            config.vrfCoordinatorV2_5,
            subId,
            config.link,
            config.account
        );

        // Assert
        (uint96 balance,,,,) = vrfCoordinator.getSubscription(subId);
        assertEq(balance, 3 ether);
    }

    //Add Consumer Test

    function testAddConsumerAddsRaffle() public {
        // Arrange
        vm.startBroadcast(config.account);
        uint256 subId = vrfCoordinator.createSubscription();
        vm.stopBroadcast();

        AddConsumer addConsumer = new AddConsumer();

        // Act
        addConsumer.addConsumer(
            address(raffle),
            config.vrfCoordinatorV2_5,
            subId,
            config.account
        );

        // Assert
        (,,,, address[] memory consumers) = vrfCoordinator.getSubscription(subId);
        assertEq(consumers.length, 1);
        assertEq(consumers[0], address(raffle));
    }

    //Network Test

    modifier skipFork() {
        if (block.chainid != LOCAL_CHAIN_ID) {
            return;
        }
        _;
    }

    function testWorksOnCorrectNetwork() public skipFork {
        // Arrange
        CreateSubscription createSub = new CreateSubscription();
        (uint256 subId,) = createSub.createSubscription(
            config.vrfCoordinatorV2_5,
            config.account
        );

        FundSubscription fundSub = new FundSubscription();
        fundSub.fundSubscription(
            config.vrfCoordinatorV2_5,
            subId,
            config.link,
            config.account
        );

        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
            address(raffle),
            config.vrfCoordinatorV2_5,
            subId,
            config.account
        );

        // Assert - All operations succeeded
        (uint96 balance,,,,) = vrfCoordinator.getSubscription(subId);
        (,,,, address[] memory consumers) = vrfCoordinator.getSubscription(subId);
        
        assert(balance > 0);
        assertEq(consumers.length, 1);
        assertEq(consumers[0], address(raffle));
    }
}

