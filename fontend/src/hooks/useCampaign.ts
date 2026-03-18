import { ethers } from "ethers";
import { useWeb3 } from "./useWeb3";
import { CampaignAbi } from "@/config/campaignAbi";

export const useCampaign = () => {
  const { signer } = useWeb3();
  const contribute = async (address: string, value: string) => {
    if (!signer) return;
    const contract = await new ethers.Contract(address, CampaignAbi, signer);
    const tx = await contract.contribute({
      value: ethers.parseEther(value),
    });
    const receipt = await tx.wait();
    console.log("%c Line:14 🍰 tx", "color:#fca650", tx.hash);
    console.log("%c Line:15 🥤 receipt", "color:#4fff4B", receipt);
  };

  const start = async (address: string) => {
    if (!signer) return;
    const contract = await new ethers.Contract(address, CampaignAbi, signer);
    const tx = await contract.start();
    console.log("%c Line:22 🥔 tx", "color:#e41a6a", tx);
    const receipt = await tx.wait();
    console.log("%c Line:24 🌶 receipt", "color:#b03734", receipt);
  };
  return {
    contribute,
    start,
  };
};
