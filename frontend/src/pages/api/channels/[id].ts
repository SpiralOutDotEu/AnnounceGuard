import { ethers } from 'ethers';
import { NextApiRequest, NextApiResponse } from 'next';
import AnnouncementHubABI from '../../../abi/AnnouncementHub.json';
import AnnouncementChannelABI from '../../../abi/AnnouncementChannel.json';

const handler = async (req: NextApiRequest, res: NextApiResponse) => {
    if (req.method === 'GET') {
        const { id } = req.query;
        const page: number = Number(req.query.page) || 1;
        const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
        const announcementHubContract = new ethers.Contract(process.env.HUB_CONTRACT_ADDRESS as string, AnnouncementHubABI.abi, provider);

        try {
            // Fetching channel name and address from AnnouncementHub contract
            const [channelName, channelAddress] = await announcementHubContract.getChannel(Number(id));

            // Connecting to AnnouncementChannel contract using the fetched address
            const announcementChannelContract = new ethers.Contract(channelAddress, AnnouncementChannelABI.abi, provider);

            // Fetching announcements and safe announcements
            const totalAnnouncementsBigInt = await announcementChannelContract.announcementCount();
            const totalSafeAnnouncementsBigInt = await announcementChannelContract.safeAnnouncementCount();
            // Convert BigInt to number (be cautious if the BigInt value is very large)
            const totalAnnouncements = Number(totalAnnouncementsBigInt.toString());
            const totalSafeAnnouncements = Number(totalSafeAnnouncementsBigInt.toString());


            // Calculate pagination parameters
            const startIdx = (page - 1) * 10;
            const endIdx = Math.min(startIdx + 10, totalAnnouncements);

            // Fetching paginated announcements and safe announcements
            const announcementsPromises = [];
            const safeAnnouncementsPromises = [];
            for (let i = startIdx; i < endIdx; i++) {
                announcementsPromises.push(announcementChannelContract.getAnnouncement(i));
                safeAnnouncementsPromises.push(announcementChannelContract.getSafeAnnouncement(i));
            }
            const announcements = await Promise.all(announcementsPromises);
            const safeAnnouncements = await Promise.all(safeAnnouncementsPromises);

            // Formatting the data for response
            const responseData = {
                channelName,
                channelAddress,
                announcements,
                safeAnnouncements,
                totalPages: Math.ceil(totalAnnouncements / 10),
            };

            res.status(200).json(responseData);
        } catch (error) {
            console.error(error);
            res.status(500).json({ error: 'Server error' });
        }
    } else {
        res.status(405).json({ error: 'Method not allowed' });
    }
};

export default handler;