import React from 'react';
import { Zap, Lock, TrendingUp, Users, ShieldAlert, Headphones, CheckCircle2 } from 'lucide-react';

export default function Features() {
  const features = [
    {
      title: 'PhonePe Auto-Return Protocol',
      description: 'Zero manual withdrawal requests. As soon as your daily trading income touches ₹100.00, our automated NPCI gateway triggers remittance straight to your verified PhonePe UPI.',
      icon: Zap,
      gradient: 'from-purple-500/20 via-indigo-500/10 to-transparent',
      borderColor: 'border-purple-500/30',
      tag: 'AUTOMATED WITHDRAWAL',
      badgeColor: 'text-purple-400 bg-purple-500/10 border-purple-500/20',
    },
    {
      title: 'AES-256 Bank-Grade Encryption',
      description: 'Your mobile numbers, UPI VPA handles, and financial transaction records are encrypted at rest using AES-256-CBC with individual Initialization Vectors (IVs) and blind HMAC hashing.',
      icon: Lock,
      gradient: 'from-cyan-500/20 via-blue-500/10 to-transparent',
      borderColor: 'border-cyan-500/30',
      tag: 'MILITARY SECURITY',
      badgeColor: 'text-cyan-400 bg-cyan-500/10 border-cyan-500/20',
    },
    {
      title: '2.5% Daily Compound Yield',
      description: 'Liquidity providers enjoy predictable 2.5% daily yield increments automatically calculated and credited to their vaults every 24 hours at 00:00:00 midnight.',
      icon: TrendingUp,
      gradient: 'from-emerald-500/20 via-teal-500/10 to-transparent',
      borderColor: 'border-emerald-500/30',
      tag: 'DAILY RETURNS',
      badgeColor: 'text-emerald-400 bg-emerald-500/10 border-emerald-500/20',
    },
    {
      title: '3-Tier Affiliate Profit Multiplier',
      description: 'Build a permanent financial revenue stream. Earn 5% on Tier 1 direct partners, 3% on Tier 2 referrals, and 1% on Tier 3 subordinates automatically credited to your ledger.',
      icon: Users,
      gradient: 'from-amber-500/20 via-yellow-500/10 to-transparent',
      borderColor: 'border-amber-500/30',
      tag: 'MULTI-TIER REBATES',
      badgeColor: 'text-amber-400 bg-amber-500/10 border-amber-500/20',
    },
    {
      title: 'Real-Time Solvency Reserve Engine',
      description: 'Our platform maintains a 100% full-reserve solvency model with automated emergency circuit breakers, instant kill-switches, and cryptographic ledger audits.',
      icon: ShieldAlert,
      gradient: 'from-rose-500/20 via-red-500/10 to-transparent',
      borderColor: 'border-rose-500/30',
      tag: 'FULL-RESERVE BACKING',
      badgeColor: 'text-rose-400 bg-rose-500/10 border-rose-500/20',
    },
    {
      title: '24/7 Priority Live Support Desk',
      description: 'In-app dispute resolution ticket desk. Direct solutions for pending transactions, UTR verification, and account security provided directly by SuperAdmins.',
      icon: Headphones,
      gradient: 'from-sky-500/20 via-blue-500/10 to-transparent',
      borderColor: 'border-sky-500/30',
      tag: 'IN-APP DISPUTE DESK',
      badgeColor: 'text-sky-400 bg-sky-500/10 border-sky-500/20',
    },
  ];

  return (
    <section id="features" className="py-20 md:py-28 relative">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Section Header */}
        <div className="text-center max-w-3xl mx-auto mb-16">
          <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-slate-900 border border-cyan-500/30 text-xs font-bold text-cyan-400 mb-4">
            <span>ARCHITECTURAL SUPERIORITY</span>
          </div>
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-display font-black text-white tracking-tight">
            Engineered For Frictionless Profit & Absolute Security
          </h2>
          <p className="mt-4 text-base sm:text-lg text-slate-400">
            Every component in the Quick Money ecosystem is built for speed, transparency, and zero user downtime.
          </p>
        </div>

        {/* Feature Cards Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {features.map((feature, idx) => {
            const Icon = feature.icon;
            return (
              <div
                key={idx}
                className={`p-8 rounded-3xl bg-slate-900/80 border ${feature.borderColor} bg-gradient-to-b ${feature.gradient} hover:-translate-y-1.5 transition-all duration-300 shadow-xl flex flex-col justify-between group`}
              >
                <div>
                  <div className="flex items-center justify-between mb-6">
                    <div className="w-12 h-12 rounded-2xl bg-slate-800/80 border border-white/10 flex items-center justify-center text-white shadow-inner group-hover:scale-110 transition-transform">
                      <Icon className="w-6 h-6 text-cyan-400" />
                    </div>
                    <span className={`text-[10px] font-black tracking-wider px-2.5 py-1 rounded-full border ${feature.badgeColor}`}>
                      {feature.tag}
                    </span>
                  </div>

                  <h3 className="text-xl font-display font-black text-white tracking-tight mb-3">
                    {feature.title}
                  </h3>
                  <p className="text-sm text-slate-300 leading-relaxed font-normal">
                    {feature.description}
                  </p>
                </div>

                <div className="mt-6 pt-4 border-t border-white/[0.06] flex items-center gap-2 text-xs font-semibold text-cyan-400">
                  <CheckCircle2 className="w-4 h-4 text-emerald-400" />
                  <span>Integrated in Android APK</span>
                </div>
              </div>
            );
          })}
        </div>

      </div>
    </section>
  );
}
