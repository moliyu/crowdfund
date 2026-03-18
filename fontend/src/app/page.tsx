"use client";
import { Header } from "@/components/Header";
import { useFactory } from "@/hooks/useFactory";
import { useWeb3 } from "@/hooks/useWeb3";

export default function Page() {
  const { connectWallet, isConnecting, account } = useWeb3();
  const {} = useFactory();

  return (
    <div className="min-h-screen relative overflow-hidden">
      <div className="fixed inset-0 -z-10">
        <div className="absolute inset-0 bg-linear-to-br from-slate-50 via-blue-50/30"></div>
        <div className="absolute inset-0 bg-[linear-gradient(to_right,#80808012_1px,transparent_1px),linear-gradient(to_bottom,#80808012_1px,transparent_1px)] bg-size-[24px_24px]" />

        {/* 装饰性光晕 */}
        <div className="absolute top-0 left-1/4 w-96 h-96 bg-primary-500/10 rounded-full blur-3xl animate-pulse" />
        <div className="absolute bottom-0 right-1/4 w-96 h-96 bg-purple-500/10 rounded-full blur-3xl animate-pulse delay-1000" />
      </div>
      <Header />

      <div className="container">{account && 123}</div>
    </div>
  );
}
