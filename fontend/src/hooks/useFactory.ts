import { useWeb3 } from "./useWeb3";
import { ethers } from "ethers";
import { FACTORY_ADDRESS } from "@/config";
import { factoryAbi } from "@/config/factoryAbi";

export type Create = {
  name: string;
  goal: string;
  durationIndayjs: number;
};

export const useFactory = ({ name, goal, durationIndayjs }: Create) => {
  const { signer } = useWeb3();

  const createCrowdFunding = async () => {
    if (!signer) {
      alert("请先连接钱包");
      return;
    }

    try {
      const contract = await new ethers.Contract(
        FACTORY_ADDRESS,
        factoryAbi,
        signer,
      );

      const tx = await contract.createCampaign(name, goal, durationIndayjs);
      const receipt = await tx.wait();
      return receipt;
    } catch (error) {
      console.log("%c Line:32 🍊 error", "color:#42b983", error);
      throw error;
    }
  };

  return {
    createCrowdFunding,
  };
};
