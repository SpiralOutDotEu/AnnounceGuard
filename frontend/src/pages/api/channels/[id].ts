import { ethers } from 'ethers';
import { NextApiRequest, NextApiResponse } from 'next';
import ABI from '../../../abi/AnnouncementHub.json';

const handler = async (req: NextApiRequest, res: NextApiResponse) => {
  if (req.method === 'GET') {
    try {
      const { id } = req.query;
      const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
      const contract = new ethers.Contract(process.env.HUB_CONTRACT_ADDRESS as string, ABI.abi, provider);
      const channel = await contract.getChannel(Number(id));
      res.status(200).json({ data: channel });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  } else {
    res.status(405).json({ error: 'Method not allowed' });
  }
};

export default handler;