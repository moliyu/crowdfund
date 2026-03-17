import { Web3Conetxt } from "@/components/Web3Provider";
import { useContext } from "react";

export const useWeb3 = () => {
  const context = useContext(Web3Conetxt)!;
  return context;
};
