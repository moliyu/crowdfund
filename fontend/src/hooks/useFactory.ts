import { useWeb3 } from "./useWeb3";
import { ethers } from "ethers";
import { FACTORY_ADDRESS } from "@/config";
import { factoryAbi } from "@/config/factoryAbi";
import { useEffect, useState } from "react";
import { CampaignAbi } from "@/config/campaignAbi";

export type Create = {
  name: string;
  goal: string;
  durationIndayjs: bigint;
};

export enum State {
  Preparing,
  Active,
  Success,
  Failed,
  Close,
}

export type Campaign = {
  address: string;
  name: string;
  goal: bigint;
  deadline: bigint;
  totalRaised: number;
  progress: number;
  contributors: string[];
  state: State;
};

export const useFactory = () => {
  const { signer, provider } = useWeb3();
  const [campaigns, setCampaigns] = useState<Campaign[]>([]);

  const createCrowdFunding = async ({
    name,
    goal,
    durationIndayjs,
  }: Create) => {
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

      const tx = await contract.createCampaign(
        name,
        ethers.parseEther(goal),
        durationIndayjs,
      );
      const receipt = await tx.wait();
      return receipt;
    } catch (error) {
      console.log("%c Line:32 🍊 error", "color:#42b983", error);
      throw error;
    }
  };

  const fetchCampaigns = async () => {
    if (!provider) {
      return;
    }

    const contract = await new ethers.Contract(
      FACTORY_ADDRESS,
      factoryAbi,
      provider,
    );
    const addressList = await contract.getCampaigns();
    const promiseFn = addressList.map(async (address) => {
      const contract = await new ethers.Contract(
        address,
        CampaignAbi,
        provider,
      );
      const [name, state, goal, totalRaised, deadline, progress, contributors] =
        await Promise.all([
          contract.name(),
          contract.state(),
          contract.goal(),
          contract.totalRaised(),
          contract.deadline(),
          contract.getProgress(),
          contract.getContributors(),
        ]);

      const campaign: Campaign = {
        address,
        name,
        state: Number(state),
        goal,
        totalRaised,
        deadline,
        progress,
        contributors,
      };
      return campaign;
    });

    const list = await Promise.all(promiseFn);
    setCampaigns(list);
  };

  return {
    createCrowdFunding,
    campaigns,
    fetchCampaigns,
  };
};
