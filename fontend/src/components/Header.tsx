"use client";
import { useWeb3 } from "@/hooks/useWeb3";
import Link from "next/link";

export const Header = () => {
  const { account, isConnecting, disconnect, connectWallet } = useWeb3();
  console.log("%c Line:7 🍢 account", "color:#465975", account);
  return (
    <header className="bg-white shadow-sm border-b border-gray-200">
      <div className="container mx-auto p-4">
        <div className="flex items-center justify-between">
          <Link
            href="/"
            className="text-2xl font-bold text-primary-600 hover:text-primary-700 transition-colors"
          >
            CrowdFund
          </Link>
          <div className="flex items-center gap-4">
            {account ? (
              <>
                <div>当前链接地址{account}</div>
                <button className="btn btn-neutral" onClick={disconnect}>
                  断开连接
                </button>
              </>
            ) : (
              <button
                className="btn btn-primary"
                onClick={connectWallet}
                disabled={isConnecting}
              >
                {isConnecting ? "连接中..." : "链接钱包"}
              </button>
            )}
          </div>
        </div>
      </div>
    </header>
  );
};
