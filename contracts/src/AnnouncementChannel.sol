// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract AnnouncementChannel {
    using ECDSA for bytes32;

    struct Announcement {
        string title;
        string body;
        address[] signers;
        bool isEmitted;
    }

    struct SafeAnnouncement {
        bytes32 contentHash;
        string title;
        string body;
        address[] signers;
        bool isRevealed;
    }

    struct MemberProposal {
        address target;
        bool isAddition;
        address[] voters;
        bool executed;
    }

    struct ThresholdProposal {
        uint256 newThreshold;
        address[] voters;
        bool executed;
    }

    event AnnouncementEmitted(uint256 announcementId, string title, string body, address[] signers);
    event SafeAnnouncementEmitted(uint256 announcementId, string title, string body, address[] signers);

    string public name;
    uint256 public safeAnnouncementCount = 0;
    uint256 public memberProposalCount = 0;
    uint256 public thresholdProposalCount = 0;
    uint256 public announcementCount = 0;
    uint256 public signingThreshold;
    mapping(address => bool) public members;
    mapping(uint256 => MemberProposal) public memberProposals;
    mapping(uint256 => ThresholdProposal) public thresholdProposals;
    mapping(uint256 => Announcement) public announcements;
    mapping(uint256 => SafeAnnouncement) public safeAnnouncements;

    modifier onlyMember() {
        require(members[msg.sender], "Not a member");
        _;
    }

    constructor(string memory _name, address[] memory _initialMembers, uint256 _initialThreshold) {
        name = _name;
        signingThreshold = _initialThreshold;
        members[msg.sender] = true;
        for (uint256 i = 0; i < _initialMembers.length; i++) {
            members[_initialMembers[i]] = true;
        }
    }

    function proposeMemberChange(address _target, bool _isAddition) public onlyMember returns (uint256) {
        MemberProposal storage proposal = memberProposals[memberProposalCount++];
        proposal.target = _target;
        proposal.isAddition = _isAddition;
        return memberProposalCount - 1;
    }

    function voteOnMemberProposal(uint256 _proposalId) public onlyMember {
        MemberProposal storage proposal = memberProposals[_proposalId];
        require(!proposal.executed, "Proposal already executed");

        for (uint256 i = 0; i < proposal.voters.length; i++) {
            require(proposal.voters[i] != msg.sender, "Already voted");
        }

        proposal.voters.push(msg.sender);
        if (proposal.voters.length >= signingThreshold) {
            proposal.executed = true;
            members[proposal.target] = proposal.isAddition;
        }
    }

    function proposeThresholdChange(uint256 _newThreshold) public onlyMember returns (uint256) {
        ThresholdProposal storage proposal = thresholdProposals[thresholdProposalCount++];
        proposal.newThreshold = _newThreshold;
        return thresholdProposalCount - 1;
    }

    function voteOnThresholdProposal(uint256 _proposalId) public onlyMember {
        ThresholdProposal storage proposal = thresholdProposals[_proposalId];
        require(!proposal.executed, "Proposal already executed");

        for (uint256 i = 0; i < proposal.voters.length; i++) {
            require(proposal.voters[i] != msg.sender, "Already voted");
        }

        proposal.voters.push(msg.sender);
        if (proposal.voters.length >= signingThreshold) {
            proposal.executed = true;
            signingThreshold = proposal.newThreshold;
        }
    }

    function proposeAnnouncement(string memory _title, string memory _body) public onlyMember returns (uint256) {
        Announcement storage newAnnouncement = announcements[announcementCount++];
        newAnnouncement.title = _title;
        newAnnouncement.body = _body;
        return announcementCount - 1;
    }

    function signAnnouncement(uint256 _announcementId) public onlyMember {
        Announcement storage announcement = announcements[_announcementId];
        require(!announcement.isEmitted, "Announcement already emitted");

        for (uint256 i = 0; i < announcement.signers.length; i++) {
            require(announcement.signers[i] != msg.sender, "Already signed");
        }

        announcement.signers.push(msg.sender);

        if (announcement.signers.length >= signingThreshold) {
            announcement.isEmitted = true;
            emit AnnouncementEmitted(_announcementId, announcement.title, announcement.body, announcement.signers);
        }
    }

    function proposeSafeAnnouncement(bytes32 _contentHash) public onlyMember returns (uint256) {
        SafeAnnouncement storage newAnnouncement = safeAnnouncements[safeAnnouncementCount++];
        newAnnouncement.contentHash = _contentHash;
        return safeAnnouncementCount - 1;
    }

    function signSafeAnnouncement(uint256 _announcementId) public onlyMember {
        SafeAnnouncement storage announcement = safeAnnouncements[_announcementId];
        require(!announcement.isRevealed, "Announcement already revealed");

        for (uint256 i = 0; i < announcement.signers.length; i++) {
            require(announcement.signers[i] != msg.sender, "Already signed");
        }

        announcement.signers.push(msg.sender);
    }

    function revealSafeAnnouncement(uint256 _announcementId, string memory _title, string memory _body)
        public
        onlyMember
    {
        SafeAnnouncement storage announcement = safeAnnouncements[_announcementId];
        require(!announcement.isRevealed, "Announcement already revealed");
        require(announcement.signers.length >= signingThreshold, "Signing threshold not reached");

        bytes32 contentHash = keccak256(abi.encodePacked(_title, _body));
        require(contentHash == announcement.contentHash, "Content hash mismatch");

        announcement.isRevealed = true;
        announcement.title = _title;
        announcement.body = _body;
        emit SafeAnnouncementEmitted(_announcementId, _title, _body, announcement.signers);
    }

    function getAnnouncement(uint256 _announcementId)
        public
        view
        returns (string memory title, string memory body, address[] memory signers, bool isEmitted)
    {
        Announcement storage announcement = announcements[_announcementId];
        return (announcement.title, announcement.body, announcement.signers, announcement.isEmitted);
    }

    function getSafeAnnouncement(uint256 _announcementId)
        public
        view
        returns (
            bytes32 contentHash,
            string memory title,
            string memory body,
            address[] memory signers,
            bool isRevealed
        )
    {
        SafeAnnouncement storage safeAnnouncement = safeAnnouncements[_announcementId];
        return (
            safeAnnouncement.contentHash,
            safeAnnouncement.title,
            safeAnnouncement.body,
            safeAnnouncement.signers,
            safeAnnouncement.isRevealed
        );
    }
}
