"use client";

import { ethers } from "ethers";
import React, { createContext, useEffect, useState } from "react";

interface web3ContextType {
  provider?: ethers.Provider;
  signer?: ethers.Signer;
  account?: string;
  connectWallet: () => Promise<void>;
  disconnect: () => void;
  isConnecting: boolean;
}

export const Web3Conetxt = createContext<web3ContextType | undefined>(
  undefined,
);

const SEPOLIA_CHAINID = BigInt(11155111);
console.log(
  "%c Line:20 🥟 SEPOLIA_CHAINID",
  "color:#4fff4B",
  SEPOLIA_CHAINID,
  ethers.toQuantity(SEPOLIA_CHAINID),
);
async function switchToSepolia() {
  if (!window.ethereum) return;
  const sepoliaId = ethers.toQuantity(SEPOLIA_CHAINID);
  try {
    await window.ethereum.request({
      method: "wallet_switchEthereumChain",
      params: [{ chainId: sepoliaId }],
    });
  } catch (error: any) {}
}

export const Web3Provider = ({ children }: { children: React.ReactNode }) => {
  const [provider, setProvider] = useState<ethers.Provider>();
  const [signer, setSigner] = useState<ethers.Signer>();
  const [account, setAccount] = useState<string>();
  const connectWallet = async () => {
    if (!window.ethereum) {
      alert("please install metamask");
      return;
    }

    try {
      setIsConnecting(true);
      let provider = new ethers.BrowserProvider(window.ethereum);
      const network = await provider.getNetwork();
      if (network.chainId != SEPOLIA_CHAINID) {
        await switchToSepolia();
        provider = new ethers.BrowserProvider(window.ethereum);
      }
      const accounts = (await provider.send(
        "eth_requestAccounts",
        [],
      )) as string[];
      const signer = await provider.getSigner();
      setProvider(provider);
      setSigner(signer);
      setAccount(accounts[0]);
    } catch (error) {
      console.log("%c Line:61 🍣 error", "color:#42b983", error);
    } finally {
      setIsConnecting(false);
    }
  };
  const disconnect = () => {
    setAccount(undefined);
    setSigner(undefined);
  };
  const [isConnecting, setIsConnecting] = useState(false);

  useEffect(() => {
    if (!window.ethereum) return;
    let provider = new ethers.BrowserProvider(window.ethereum);
    provider.getNetwork().then(async (network) => {
      if (network.chainId != SEPOLIA_CHAINID) {
        await switchToSepolia();
        if (!window.ethereum) return;
        provider = new ethers.BrowserProvider(window.ethereum);
      }
      setProvider(provider);
      const accounts = (await window.ethereum!.request({
        method: "eth_accounts",
      })) as string[];
      console.log("%c Line:89 🍧 accounts", "color:#e41a6a", accounts);
      if (accounts.length) {
        const signer = await provider.getSigner();
        setSigner(signer);
        setAccount(accounts[0]);
      }
    });
  }, []);

  return (
    <Web3Conetxt.Provider
      value={{
        provider,
        signer,
        account,
        connectWallet,
        disconnect,
        isConnecting,
      }}
    >
      {children}
    </Web3Conetxt.Provider>
  );
};
