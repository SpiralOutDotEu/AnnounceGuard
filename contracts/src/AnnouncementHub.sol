// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./AnnouncementChannel.sol";

contract AnnouncementHub {
    struct Channel {
        string name;
        address channelAddress;
    }

    Channel[] public channels;
    uint256 public channelsCounter;

    event ChannelCreated(uint256 id , string name, address channelAddress);

    function createChannel(string memory _name, address[] memory _initialMembers, uint256 _initialThreshold)
        public
        returns (address)
    {
        AnnouncementChannel newChannel = new AnnouncementChannel(_name, _initialMembers, _initialThreshold);
        channels.push(Channel({name: _name, channelAddress: address(newChannel)}));
        emit ChannelCreated(channelsCounter, _name, address(newChannel));
        channelsCounter += 1;        
        return address(newChannel);
    }

    function getChannel(uint256 _index) public view returns (string memory, address) {
        Channel storage channelDetails = channels[_index];
        return (channelDetails.name, channelDetails.channelAddress);
    }
}
