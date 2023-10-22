// pages/api/channels/index.ts
import { ethers } from 'ethers';
import { NextApiRequest, NextApiResponse } from 'next';
import ABI from '../../../abi/AnnouncementHub.json';


const handler = async (req: NextApiRequest, res: NextApiResponse) => {
  if (req.method === 'GET') {
    try {
      const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
      const contract = new ethers.Contract(process.env.HUB_CONTRACT_ADDRESS as string, ABI.abi, provider);
      const totalChannels = await contract.channelsCounter();
      const pages = Math.ceil(Number(totalChannels) / 10);
      const pageIndex = Number(req.query.page) || 1;
      const results = [];
      for (let i = (pageIndex - 1) * 10; i < Math.min(pageIndex * 10, Number(totalChannels)); i++) {
        const channel = await contract.getChannel(i);
        results.push(channel);
      }
      res.status(200).json({ data: results, pages, totalChannels: Number(totalChannels) });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  } else {
    res.status(405).json({ error: 'Method not allowed' });
  }
};

export default handler;