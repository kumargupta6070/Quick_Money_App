import React, { useState } from 'react';
import { Download, ShieldCheck, Menu, X, ArrowUpRight } from 'lucide-react';

export default function Navbar({ release, onDownload }) {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <header className="sticky top-0 z-50 w-full backdrop-blur-xl bg-[#080C1A]/85 border-b border-white/[0.08] transition-all">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-20 flex items-center justify-between">
        
        {/* Brand Logo & Live Pulse */}
        <div className="flex items-center gap-3">
          <div className="relative flex items-center justify-center w-11 h-11 rounded-2xl bg-gradient-to-tr from-cyan-500 via-indigo-500 to-purple-600 p-[1.5px] shadow-lg shadow-cyan-500/20">
            <div className="w-full h-full bg-[#080C1A] rounded-[14px] flex items-center justify-center">
              <span className="font-display font-black text-xl text-transparent bg-clip-text bg-gradient-to-r from-cyan-400 to-amber-300">₹</span>
            </div>
          </div>
          <div>
            <div className="flex items-center gap-2">
              <span className="font-display font-black text-xl tracking-tight text-white">
                QUICK <span className="text-transparent bg-clip-text bg-gradient-to-r from-cyan-400 to-indigo-400">MONEY</span>
              </span>
              <span className="hidden sm:inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-bold bg-emerald-500/10 text-emerald-400 border border-emerald-500/30">
                <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 mr-1 animate-pulse"></span>
                MARKET ONLINE
              </span>
            </div>
            <p className="text-[10.5px] text-slate-400 font-medium tracking-wide">Automated Liquidity Protocol</p>
          </div>
        </div>

        {/* Desktop Nav Links */}
        <nav className="hidden md:flex items-center gap-8 text-sm font-medium text-slate-300">
          <a href="#overview" className="hover:text-cyan-400 transition-colors">Overview</a>
          <a href="#features" className="hover:text-cyan-400 transition-colors">Features</a>
          <a href="#how-it-works" className="hover:text-cyan-400 transition-colors">How It Works</a>
          <a href="#packages" className="hover:text-cyan-400 transition-colors">RP Packages</a>
          <a href="#download" className="hover:text-cyan-400 transition-colors flex items-center gap-1">
            Download APK
            <span className="text-[10px] bg-cyan-500/20 text-cyan-400 px-1.5 py-0.5 rounded-md font-bold">v{release?.version || '1.0.0'}</span>
          </a>
          <a href="#faq" className="hover:text-cyan-400 transition-colors">FAQ</a>
        </nav>

        {/* Action Button & Mobile Toggle */}
        <div className="flex items-center gap-3">
          <button
            onClick={onDownload}
            className="hidden sm:inline-flex items-center gap-2 px-5 py-2.5 rounded-xl font-display font-bold text-xs tracking-wide bg-gradient-to-r from-cyan-500 to-blue-600 hover:from-cyan-400 hover:to-blue-500 text-slate-950 shadow-lg shadow-cyan-500/25 hover:shadow-cyan-500/40 transition-all hover:scale-[1.02] active:scale-[0.98]"
          >
            <Download className="w-4 h-4 stroke-[2.5]" />
            <span>DOWNLOAD APK</span>
          </button>

          <button
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            className="md:hidden p-2 rounded-xl text-slate-400 hover:text-white bg-slate-800/50 border border-slate-700/50"
            aria-label="Toggle Menu"
          >
            {mobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
          </button>
        </div>
      </div>

      {/* Mobile Menu Dropdown */}
      {mobileMenuOpen && (
        <div className="md:hidden border-b border-white/[0.08] bg-[#080C1A]/95 backdrop-blur-2xl px-6 py-6 space-y-4">
          <a
            href="#overview"
            onClick={() => setMobileMenuOpen(false)}
            className="block text-base font-medium text-slate-200 hover:text-cyan-400"
          >
            Overview
          </a>
          <a
            href="#features"
            onClick={() => setMobileMenuOpen(false)}
            className="block text-base font-medium text-slate-200 hover:text-cyan-400"
          >
            Features
          </a>
          <a
            href="#how-it-works"
            onClick={() => setMobileMenuOpen(false)}
            className="block text-base font-medium text-slate-200 hover:text-cyan-400"
          >
            How It Works
          </a>
          <a
            href="#packages"
            onClick={() => setMobileMenuOpen(false)}
            className="block text-base font-medium text-slate-200 hover:text-cyan-400"
          >
            RP Packages
          </a>
          <a
            href="#download"
            onClick={() => setMobileMenuOpen(false)}
            className="block text-base font-medium text-slate-200 hover:text-cyan-400"
          >
            Download APK Hub
          </a>
          <a
            href="#faq"
            onClick={() => setMobileMenuOpen(false)}
            className="block text-base font-medium text-slate-200 hover:text-cyan-400"
          >
            FAQ
          </a>
          <button
            onClick={() => {
              setMobileMenuOpen(false);
              onDownload();
            }}
            className="w-full flex items-center justify-center gap-2 py-3 rounded-xl font-display font-bold text-sm bg-gradient-to-r from-cyan-500 to-blue-600 text-slate-950 shadow-lg shadow-cyan-500/25"
          >
            <Download className="w-4 h-4" />
            <span>Download APK (v{release?.version || '1.0.0'})</span>
          </button>
        </div>
      )}
    </header>
  );
}
