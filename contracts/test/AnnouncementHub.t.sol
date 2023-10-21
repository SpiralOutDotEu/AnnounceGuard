// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/AnnouncementHub.sol";
import "../src/AnnouncementChannel.sol";

contract AnnouncementHubTest is Test {
    AnnouncementHub hub;

    event ChannelCreated(uint256 id , string name, address channelAddress);

    function setUp() public {
        hub = new AnnouncementHub();
    }

    function test_ChannelCreation() public {
        address[] memory initialMembers = new address[](1);
        initialMembers[0] = address(this);
        uint256 initialThreshold = 1;

        vm.expectEmit(true, true, false, false, address(hub));
        emit ChannelCreated(0, "Test Channel", address(0xAFABCAFE));
        address channelAddress = hub.createChannel("Test Channel", initialMembers, initialThreshold);

        string memory name;
        address returnedAddress;
        (name, returnedAddress) = hub.getChannel(0);

        assertEq(name, "Test Channel");
        assertEq(returnedAddress, channelAddress);
    }
}
