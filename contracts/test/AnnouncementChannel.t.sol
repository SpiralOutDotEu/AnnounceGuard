// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/AnnouncementHub.sol";
import "../src/AnnouncementChannel.sol";

contract AnnouncementChannelTest is Test {
    AnnouncementChannel channel;
    address member1;
    address member2;
    address member3;

    event AnnouncementEmitted(uint256 announcementId, string title, string body, address[] signers);
    event SafeAnnouncementEmitted(uint256 announcementId, string title, string body, address[] signers);

    function setUp() public {
        member1 = address(0xAFABCAFE);
        member2 = address(0xB105F00D);
        member3 = address(0xB0BABABE);
        address[] memory initialMembers = new address[](3);
        initialMembers[0] = member1;
        initialMembers[1] = member2;
        initialMembers[2] = member3;
        uint256 initialThreshold = 2;
        channel = new AnnouncementChannel("Test Channel", initialMembers, initialThreshold);
    }

    function test_AnnouncementCreation() public {
        uint256 announcementId = channel.proposeAnnouncement("Test Announcement", "This is a test announcement.");
        channel.signAnnouncement(announcementId);

        string memory title;
        string memory body;
        address[] memory signers;
        bool isEmitted;
        (title, body, signers, isEmitted) = channel.getAnnouncement(announcementId);

        assertEq(title, "Test Announcement");
        assertEq(body, "This is a test announcement.");
        assertEq(signers[0], address(this));
    }

    function test_AnnouncementCreationAndSigning() public {
        uint256 announcementId = channel.proposeAnnouncement("Test Announcement", "This is a test announcement.");

        vm.prank(member1);
        channel.signAnnouncement(announcementId);

        vm.prank(member2);
        channel.signAnnouncement(announcementId);

        string memory title;
        string memory body;
        address[] memory signers;
        bool isEmitted;
        (title, body, signers, isEmitted) = channel.getAnnouncement(announcementId);

        assertEq(title, "Test Announcement");
        assertEq(body, "This is a test announcement.");
        assertEq(signers.length, 2);
        assertTrue(isEmitted);
    }

    function test_SafeAnnouncementSigningAndReveal() public {
        bytes32 contentHash = keccak256(abi.encodePacked("Test Safe Announcement", "This is a test safe announcement."));
        uint256 announcementId = channel.proposeSafeAnnouncement(contentHash);

        vm.prank(member1);
        channel.signSafeAnnouncement(announcementId);

        vm.prank(member2);
        channel.signSafeAnnouncement(announcementId);

        vm.prank(member1);
        channel.revealSafeAnnouncement(announcementId, "Test Safe Announcement", "This is a test safe announcement.");

        bytes32 returnedContentHash;
        string memory title;
        string memory body;
        address[] memory signers;
        bool isRevealed;
        (returnedContentHash, title, body, signers, isRevealed) = channel.getSafeAnnouncement(announcementId);

        assertEq(title, "Test Safe Announcement");
        assertEq(body, "This is a test safe announcement.");
        assertEq(signers.length, 2);
        assertTrue(isRevealed);
    }

    function test_SafeAnnouncementMismatchReveal() public {
        bytes32 contentHash = keccak256(abi.encodePacked("Test Safe Announcement", "This is a test safe announcement."));
        uint256 announcementId = channel.proposeSafeAnnouncement(contentHash);

        vm.prank(member1);
        channel.signSafeAnnouncement(announcementId);

        vm.prank(member2);
        channel.signSafeAnnouncement(announcementId);

        vm.expectRevert();
        vm.prank(member1);
        channel.revealSafeAnnouncement(announcementId, "Wrong Title", "Wrong Body");
    }

    function test_InvalidMemberSigning() public {
        uint256 announcementId = channel.proposeAnnouncement("Test Announcement", "This is a test announcement.");

        vm.prank(address(0xdead)); // Not a member
        vm.expectRevert("Not a member");
        channel.signAnnouncement(announcementId);
    }

    function test_InvalidMemberRevealing() public {
        bytes32 contentHash = keccak256(abi.encodePacked("Test Safe Announcement", "This is a test safe announcement."));
        uint256 announcementId = channel.proposeSafeAnnouncement(contentHash);

        vm.prank(member1);
        channel.signSafeAnnouncement(announcementId);

        vm.prank(member2);
        channel.signSafeAnnouncement(announcementId);

        vm.expectRevert("Not a member");
        vm.prank(address(0xdeadbeef)); // Not a member
        channel.revealSafeAnnouncement(announcementId, "Test Safe Announcement", "This is a test safe announcement.");
    }

    function test_AnnouncementAlreadyEmitted() public {
        uint256 announcementId = channel.proposeAnnouncement("Test Announcement", "This is a test announcement.");
        address[] memory signers = new address[](2);
        signers[0] = member1;
        signers[1] = member2;

        // First signing
        vm.prank(member1);
        channel.signAnnouncement(announcementId);

        // Second signing to trigger event emission
        vm.prank(member2);
        channel.signAnnouncement(announcementId);

        // Third signing to trigger revert
        vm.expectRevert("Announcement already emitted");
        vm.prank(member1);
        channel.signAnnouncement(announcementId);
    }

    function test_SafeAnnouncementAlreadyRevealed() public {
        bytes32 contentHash = keccak256(abi.encodePacked("Test Safe Announcement", "This is a test safe announcement."));
        uint256 announcementId = channel.proposeSafeAnnouncement(contentHash);

        vm.prank(member1);
        channel.signSafeAnnouncement(announcementId);

        vm.prank(member2);
        channel.signSafeAnnouncement(announcementId);

        vm.prank(member1);
        channel.revealSafeAnnouncement(announcementId, "Test Safe Announcement", "This is a test safe announcement.");

        vm.prank(member1);
        vm.expectRevert("Announcement already revealed");
        channel.revealSafeAnnouncement(announcementId, "Test Safe Announcement", "This is a test safe announcement.");
    }
}
