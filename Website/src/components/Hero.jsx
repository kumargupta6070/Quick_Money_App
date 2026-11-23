import React from 'react';
import { Download, ShieldCheck, Zap, ArrowRight, CheckCircle2, Smartphone, Lock, TrendingUp, Sparkles } from 'lucide-react';

export default function Hero({ release, onDownload }) {
  return (
    <section id="overview" className="relative pt-12 pb-24 md:pt-20 md:pb-32 overflow-hidden">
      
      {/* Dynamic Ambient Background Orbs */}
      <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[650px] h-[650px] bg-gradient-to-tr from-cyan-600/20 via-indigo-600/15 to-purple-600/20 rounded-full blur-[130px] -z-10 pointer-events-none animate-pulse-slow"></div>
      <div className="absolute top-10 right-10 w-80 h-80 bg-amber-500/10 rounded-full blur-[100px] -z-10 pointer-events-none"></div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 lg:gap-8 items-center">
          
          {/* Left Column: Headline & Call To Actions */}
          <div className="lg:col-span-7 text-center lg:text-left">
            
            {/* Trust Pill */}
            <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-slate-900/90 border border-cyan-500/30 text-xs font-semibold text-cyan-400 mb-6 shadow-inner">
              <Sparkles className="w-3.5 h-3.5 text-amber-400" />
              <span>NPCI PHONEPE PROTOCOL • AES-256 VAULT • 2.5% DAILY YIELD</span>
            </div>

            {/* Main Title */}
            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-display font-black tracking-tight text-white leading-[1.12]">
              Institutional RP Trading With{' '}
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-cyan-400 via-sky-300 to-indigo-400">
                Automated PhonePe
              </span>{' '}
              Liquidity Returns.
            </h1>

            {/* Subtitle */}
            <p className="mt-6 text-base sm:text-lg text-slate-300 font-normal leading-relaxed max-w-2xl mx-auto lg:mx-0">
              Deploy liquidity into high-yield RP order tiers, collect 2.5% daily automated interest, and enjoy instant, friction-free remittance directly into your bound PhonePe UPI without manual withdrawal delays.
            </p>

            {/* Download CTA & Badges */}
            <div className="mt-8 flex flex-col sm:flex-row items-center justify-center lg:justify-start gap-4">
              <button
                onClick={onDownload}
                className="w-full sm:w-auto flex items-center justify-center gap-3 px-8 py-4 rounded-2xl font-display font-extrabold text-sm sm:text-base tracking-wide bg-gradient-to-r from-cyan-400 via-cyan-500 to-blue-600 hover:from-cyan-300 hover:to-blue-500 text-slate-950 shadow-xl shadow-cyan-500/30 hover:shadow-cyan-500/50 transition-all hover:scale-[1.02] active:scale-[0.98] group"
              >
                <Download className="w-5 h-5 stroke-[2.5] group-hover:-translate-y-0.5 transition-transform" />
                <span>DOWNLOAD ANDROID APK</span>
                <span className="px-2 py-0.5 rounded-md text-[11px] font-black bg-slate-950/20 text-slate-900">
                  v{release?.version || '1.0.0'}
                </span>
              </button>

              <a
                href="#packages"
                className="w-full sm:w-auto flex items-center justify-center gap-2 px-6 py-4 rounded-2xl font-display font-bold text-sm tracking-wide bg-slate-900/80 hover:bg-slate-800 text-white border border-slate-700/60 hover:border-slate-600 transition-all"
              >
                <span>View Packages</span>
                <ArrowRight className="w-4 h-4 text-cyan-400" />
              </a>
            </div>

            {/* Android Compatibility & Security Notice */}
            <div className="mt-6 flex flex-wrap items-center justify-center lg:justify-start gap-y-2 gap-x-6 text-xs text-slate-400 font-medium">
              <span className="flex items-center gap-1.5">
                <CheckCircle2 className="w-4 h-4 text-emerald-400" />
                Size: {release?.file_size || '28.4 MB'}
              </span>
              <span className="flex items-center gap-1.5">
                <CheckCircle2 className="w-4 h-4 text-emerald-400" />
                Android 8.0+ Ready
              </span>
              <span className="flex items-center gap-1.5">
                <CheckCircle2 className="w-4 h-4 text-emerald-400" />
                Play Protect Verified
              </span>
            </div>
          </div>

          {/* Right Column: Realistic Interactive Mobile Mockup */}
          <div className="lg:col-span-5 flex justify-center">
            <div className="relative w-full max-w-[340px]">
              
              {/* Outer Glow Halo */}
              <div className="absolute inset-0 bg-gradient-to-tr from-cyan-500/30 to-purple-600/30 rounded-[44px] blur-2xl -z-10 transform scale-95"></div>

              {/* Smartphone Outer Chassis */}
              <div className="relative rounded-[42px] p-3.5 bg-gradient-to-b from-slate-700 via-slate-900 to-black shadow-2xl border border-slate-700/60">
                
                {/* Dynamic Screen */}
                <div className="rounded-[32px] overflow-hidden bg-[#0A0F24] border border-slate-800 p-4 space-y-4 text-left">
                  
                  {/* Mockup Status Bar */}
                  <div className="flex justify-between items-center text-[10px] text-slate-400 font-bold px-1">
                    <span>9:41</span>
                    <div className="w-16 h-3.5 bg-black rounded-full flex items-center justify-center">
                      <div className="w-2.5 h-2.5 rounded-full bg-slate-900"></div>
                    </div>
                    <span>5G • 100%</span>
                  </div>

                  {/* App Header */}
                  <div className="flex justify-between items-center pt-1">
                    <div>
                      <p className="text-[10px] font-bold tracking-widest text-cyan-400">QUICK MONEY</p>
                      <h4 className="text-xs font-black text-white">Trading Vault</h4>
                    </div>
                    <span className="px-2 py-0.5 rounded-full text-[9px] font-extrabold bg-emerald-500/20 text-emerald-400 border border-emerald-500/30">
                      ● LIVE
                    </span>
                  </div>

                  {/* Main Balance Card */}
                  <div className="p-3.5 rounded-2xl bg-gradient-to-br from-indigo-900/60 via-slate-900 to-slate-950 border border-indigo-500/30 shadow-lg">
                    <p className="text-[10px] text-slate-400 font-medium">Total Trading Balance</p>
                    <div className="flex items-baseline justify-between mt-1">
                      <h3 className="text-2xl font-display font-black text-white">₹894.14</h3>
                      <span className="text-[10px] font-bold text-emerald-400 flex items-center gap-0.5">
                        <TrendingUp className="w-3 h-3" /> +2.5%
                      </span>
                    </div>
                    <div className="mt-2.5 pt-2 border-t border-white/[0.08] flex items-center justify-between text-[10px] text-slate-300">
                      <span>PhonePe Auto-Return:</span>
                      <span className="text-amber-400 font-bold">At ₹100.00</span>
                    </div>
                  </div>

                  {/* PhonePe Bound Gateway Tile */}
                  <div className="p-3 rounded-xl bg-purple-950/30 border border-purple-500/30 flex items-center justify-between">
                    <div className="flex items-center gap-2.5">
                      <div className="w-8 h-8 rounded-lg bg-[#5F259F] flex items-center justify-center text-white font-black text-sm">
                        पे
                      </div>
                      <div>
                        <p className="text-[11px] font-bold text-white leading-tight">PhonePe NPCI</p>
                        <p className="text-[9.5px] text-slate-400">Auto-Return Verified</p>
                      </div>
                    </div>
                    <span className="text-[9px] font-extrabold text-emerald-400 bg-emerald-500/10 px-2 py-0.5 rounded-full border border-emerald-500/30">
                      Active
                    </span>
                  </div>

                  {/* Package Quick Preview */}
                  <div className="space-y-1.5 pt-1">
                    <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Live RP Tiers</p>
                    <div className="p-2.5 rounded-xl bg-slate-900/90 border border-slate-800 flex justify-between items-center">
                      <div>
                        <p className="text-[11px] font-bold text-white">L1 Liquidity Package</p>
                        <p className="text-[9.5px] text-slate-400">Order: ₹500 • Daily: ₹12.50</p>
                      </div>
                      <span className="px-2.5 py-1 rounded-lg text-[10px] font-bold bg-cyan-500 text-slate-950 font-display">
                        DEPLOY
                      </span>
                    </div>
                  </div>

                  {/* Security Footer inside mockup */}
                  <div className="flex items-center justify-center gap-1.5 text-[9px] text-slate-500 pt-1">
                    <Lock className="w-3 h-3 text-cyan-400" />
                    <span>Protected by AES-256 Bit Encryption</span>
                  </div>

                </div>
              </div>
            </div>
          </div>

        </div>
      </div>
    </section>
  );
}
