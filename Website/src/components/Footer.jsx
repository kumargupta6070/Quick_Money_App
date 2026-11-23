import React from 'react';
import { Mail, Shield, Smartphone, Heart, ArrowUp, ExternalLink } from 'lucide-react';

export default function Footer({ release, onDownloadClick }) {
  const scrollToTop = () => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  return (
    <footer className="bg-slate-950 border-t border-slate-800/80 pt-16 pb-12 relative overflow-hidden">
      {/* Ambient gradient */}
      <div className="absolute bottom-0 left-1/2 -translate-x-1/2 w-3/4 h-40 bg-blue-500/5 blur-[120px] pointer-events-none" />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-10 mb-12">
          {/* Brand Info */}
          <div className="space-y-4">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-blue-600 via-indigo-600 to-emerald-400 flex items-center justify-center text-white font-black text-xl shadow-lg shadow-blue-500/20">
                ₹
              </div>
              <span className="font-extrabold text-xl tracking-tight text-white font-display">
                Quick <span className="bg-gradient-to-r from-blue-400 to-emerald-400 bg-clip-text text-transparent">Money</span>
              </span>
            </div>
            <p className="text-slate-400 text-xs leading-relaxed">
              India's premier high-energy liquidity protocol and earnings ecosystem. Automated PhonePe payouts, 2.5% daily yields, and bank-grade AES-256 vault encryption.
            </p>
            <div className="flex items-center gap-2 text-xs text-emerald-400 font-semibold">
              <Shield className="w-4 h-4" />
              <span>Version {release?.version || '1.0.0'} Production Live</span>
            </div>
          </div>

          {/* Quick Navigation */}
          <div>
            <h4 className="text-xs font-bold uppercase tracking-wider text-white mb-4">Navigation</h4>
            <ul className="space-y-2.5 text-xs text-slate-400">
              <li><a href="#features" className="hover:text-blue-400 transition-colors">Key Features</a></li>
              <li><a href="#how-it-works" className="hover:text-blue-400 transition-colors">How It Works</a></li>
              <li><a href="#packages" className="hover:text-blue-400 transition-colors">Liquidity Packages</a></li>
              <li><a href="#download" className="hover:text-blue-400 transition-colors">Download Hub</a></li>
              <li><a href="#faq" className="hover:text-blue-400 transition-colors">FAQs</a></li>
            </ul>
          </div>

          {/* Security & Support */}
          <div>
            <h4 className="text-xs font-bold uppercase tracking-wider text-white mb-4">Official Contact</h4>
            <ul className="space-y-3 text-xs text-slate-400">
              <li className="flex items-center gap-2">
                <Mail className="w-4 h-4 text-blue-400 shrink-0" />
                <a href="mailto:quick.moneey.in@gmail.com" className="hover:text-white transition-colors underline decoration-slate-700">
                  quick.moneey.in@gmail.com
                </a>
              </li>
              <li className="flex items-center gap-2">
                <Smartphone className="w-4 h-4 text-emerald-400 shrink-0" />
                <span>24/7 Mobile Helpdesk In-App</span>
              </li>
              <li className="pt-2">
                <button
                  onClick={onDownloadClick}
                  className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-blue-500/10 border border-blue-500/20 text-blue-400 font-semibold hover:bg-blue-500/20 transition-colors"
                >
                  <span>Download APK</span>
                  <ExternalLink className="w-3 h-3" />
                </button>
              </li>
            </ul>
          </div>

          {/* Disclaimer */}
          <div className="space-y-3">
            <h4 className="text-xs font-bold uppercase tracking-wider text-white mb-2">Platform Notice</h4>
            <p className="text-[11px] text-slate-500 leading-relaxed">
              Quick Money protocol operates peer-to-peer liquidity orders and downline rewards. Trading and market participation carry risk. Download only verified APKs directly from this official portal.
            </p>
            <div className="pt-2">
              <button
                onClick={scrollToTop}
                className="inline-flex items-center gap-2 text-xs text-slate-400 hover:text-white transition-colors"
              >
                <ArrowUp className="w-3.5 h-3.5" /> Back to Top
              </button>
            </div>
          </div>
        </div>

        {/* Bottom Bar */}
        <div className="pt-8 border-t border-slate-800/80 flex flex-col sm:flex-row items-center justify-between gap-4 text-xs text-slate-500">
          <p>© 2026 Quick Money Protocol Inc. All rights reserved.</p>
          <div className="flex items-center gap-1">
            <span>Crafted with</span>
            <Heart className="w-3.5 h-3.5 text-rose-500 fill-rose-500 inline" />
            <span>for Indian Traders</span>
          </div>
        </div>
      </div>
    </footer>
  );
}
