import React from 'react';
import { Download, ShieldCheck, Zap, TrendingUp, Sparkles, CheckCircle2 } from 'lucide-react';

export default function HowItWorks() {
  const steps = [
    {
      step: '01',
      title: 'Download & Install APK',
      desc: 'Get the official verified Quick Money Android APK directly from this portal or scan the QR code on your phone.',
      icon: Download,
      gradient: 'from-blue-500 to-indigo-600',
      badge: 'Instant 28MB',
    },
    {
      step: '02',
      title: 'Quick OTP Registration',
      desc: 'Verify your email with ultra-fast 2-second OTP authentication. Receive ₹100 welcome bonus immediately in your secure vault.',
      icon: Zap,
      gradient: 'from-amber-400 to-orange-500',
      badge: '₹100 Bonus',
    },
    {
      step: '03',
      title: 'Choose Liquidity Tier',
      desc: 'Deploy orders starting from just ₹500 across L1 to L5 tiers. Enjoy 2.5% daily yields with military-grade AES-256 encryption.',
      icon: TrendingUp,
      gradient: 'from-emerald-400 to-teal-600',
      badge: '2.5% Daily',
    },
    {
      step: '04',
      title: 'Direct PhonePe Payouts',
      desc: 'Withdraw your daily gains directly into your PhonePe UPI wallet with automated instant settlement verification.',
      icon: ShieldCheck,
      gradient: 'from-purple-500 to-pink-600',
      badge: '0% Platform Fee',
    },
  ];

  return (
    <section id="how-it-works" className="py-24 relative overflow-hidden bg-slate-950/60">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div className="text-center max-w-3xl mx-auto mb-16">
          <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-blue-500/10 border border-blue-500/20 text-blue-400 text-xs font-semibold uppercase tracking-wider mb-4">
            <Sparkles className="w-3.5 h-3.5" />
            Seamless 4-Step Journey
          </div>
          <h2 className="text-3xl sm:text-5xl font-black text-white tracking-tight mb-4 font-display">
            How Quick Money <span className="bg-gradient-to-r from-blue-400 via-indigo-300 to-emerald-400 bg-clip-text text-transparent">Powers Your Daily Gains</span>
          </h2>
          <p className="text-slate-400 text-base sm:text-lg">
            From downloading the APK to your first automated PhonePe payout in under 3 minutes.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 relative">
          {steps.map((item, index) => {
            const Icon = item.icon;
            return (
              <div 
                key={index} 
                className="relative group rounded-3xl p-6 bg-slate-900/60 border border-slate-800/80 hover:border-slate-700 transition-all duration-300 hover:-translate-y-1.5 hover:shadow-2xl hover:shadow-blue-500/10 backdrop-blur-xl"
              >
                {/* Step badge */}
                <div className="flex items-center justify-between mb-6">
                  <div className={`w-12 h-12 rounded-2xl bg-gradient-to-br ${item.gradient} flex items-center justify-center text-white shadow-lg`}>
                    <Icon className="w-6 h-6" />
                  </div>
                  <span className="text-3xl font-black text-slate-800 group-hover:text-slate-700 transition-colors font-display">
                    {item.step}
                  </span>
                </div>

                <div className="inline-block px-2.5 py-1 rounded-md bg-white/5 border border-white/10 text-xs font-semibold text-slate-300 mb-3">
                  {item.badge}
                </div>

                <h3 className="text-lg font-bold text-white mb-2 group-hover:text-blue-300 transition-colors">
                  {item.title}
                </h3>
                
                <p className="text-slate-400 text-sm leading-relaxed">
                  {item.desc}
                </p>

                <div className="mt-5 pt-4 border-t border-slate-800/60 flex items-center gap-2 text-xs text-slate-500 font-medium">
                  <CheckCircle2 className="w-4 h-4 text-emerald-400" /> Verified Instant Execution
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
