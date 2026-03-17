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
                <button
                  onClick={disconnect}
                  className="flex items-center gap-2 px-4 py-2 bg-primary-50 dark:bg-primary-900/20 rounded-lg border border-primary-200 dark:border-primary-800 hover:bg-primary-100 dark:hover:bg-primary-900/30 hover:border-primary-300 dark:hover:border-primary-700 transition-all cursor-pointer group"
                >
                  断开连接
                </button>
              </>
            ) : (
              <button
                className="cursor-pointer bg-blue-500"
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
