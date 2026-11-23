import React from 'react';
import { Layers, ShieldCheck, ArrowRight, Zap, Check } from 'lucide-react';

export default function Packages({ onDownloadClick }) {
  const tiers = [
    {
      level: 'L1',
      title: 'Starter Liquidity',
      amount: '500',
      dailyYield: '2.5%',
      dailyAmount: '₹12.50',
      bonus: '2.0% Launch Bonus',
      popular: false,
      color: 'from-blue-500 to-cyan-500',
      badgeColor: 'bg-blue-500/10 text-blue-400 border-blue-500/20',
      features: ['Min Entry: ₹500', 'Automated Daily Returns', 'PhonePe Auto Payouts', 'L1-L3 Referral Bonus', 'Standard Support'],
    },
    {
      level: 'L2',
      title: 'Growth Vault',
      amount: '2,000',
      dailyYield: '2.5%',
      dailyAmount: '₹50.00',
      bonus: '3.5% Speed Bonus',
      popular: false,
      color: 'from-cyan-500 to-teal-500',
      badgeColor: 'bg-teal-500/10 text-teal-400 border-teal-500/20',
      features: ['Min Entry: ₹2,000', 'Automated Daily Returns', 'Priority UPI Settlement', 'Accelerated Downline Rewards', 'Live Ticket Helpdesk'],
    },
    {
      level: 'L3',
      title: 'Premium Protocol',
      amount: '5,000',
      dailyYield: '2.5%',
      dailyAmount: '₹125.00',
      bonus: '5.0% VIP Booster',
      popular: true,
      color: 'from-emerald-500 to-green-600',
      badgeColor: 'bg-emerald-500/10 text-emerald-400 border-emerald-500/20',
      features: ['Min Entry: ₹5,000', 'Automated Daily Returns', 'Zero Withdrawal Processing Delay', 'Max 3-Tier Multiplier', 'Dedicated VIP Assistance'],
    },
    {
      level: 'L4',
      title: 'Elite Capital',
      amount: '10,000',
      dailyYield: '2.5%',
      dailyAmount: '₹250.00',
      bonus: '7.5% Prime Bonus',
      popular: false,
      color: 'from-purple-500 to-indigo-600',
      badgeColor: 'bg-purple-500/10 text-purple-400 border-purple-500/20',
      features: ['Min Entry: ₹10,000', 'Automated Daily Returns', 'Guaranteed Solvency Allocation', 'Special High-Volume Tier', 'Priority Phone Support'],
    },
    {
      level: 'L5',
      title: 'Institutional Vault',
      amount: '25,000',
      dailyYield: '2.5%',
      dailyAmount: '₹625.00',
      bonus: '10.0% Sovereign Allocation',
      popular: false,
      color: 'from-amber-500 to-rose-500',
      badgeColor: 'bg-amber-500/10 text-amber-400 border-amber-500/20',
      features: ['Min Entry: ₹25,000', 'Automated Daily Returns', 'Direct PhonePe Enterprise Batch', 'Maximum Downline Network Share', 'Dedicated Account Manager'],
    },
  ];

  return (
    <section id="packages" className="py-24 relative overflow-hidden">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div className="text-center max-w-3xl mx-auto mb-16">
          <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs font-semibold uppercase tracking-wider mb-4">
            <Layers className="w-3.5 h-3.5" />
            Transparent Tiers
          </div>
          <h2 className="text-3xl sm:text-5xl font-black text-white tracking-tight mb-4 font-display">
            High-Yield <span className="bg-gradient-to-r from-emerald-400 via-teal-300 to-blue-400 bg-clip-text text-transparent">Liquidity Packages</span>
          </h2>
          <p className="text-slate-400 text-base sm:text-lg">
            Choose your preferred market tier inside the app. Transparent daily yields credited automatically every 24 hours.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-6">
          {tiers.map((tier, idx) => (
            <div
              key={idx}
              className={`relative rounded-3xl p-6 flex flex-col justify-between transition-all duration-300 hover:-translate-y-2 backdrop-blur-xl ${
                tier.popular
                  ? 'bg-gradient-to-b from-slate-900 via-slate-900/90 to-emerald-950/30 border-2 border-emerald-500/60 shadow-2xl shadow-emerald-500/20'
                  : 'bg-slate-900/60 border border-slate-800 hover:border-slate-700 hover:shadow-xl'
              }`}
            >
              {tier.popular && (
                <div className="absolute -top-3.5 left-1/2 -translate-x-1/2 px-3 py-1 rounded-full bg-gradient-to-r from-emerald-500 to-teal-500 text-slate-950 font-black text-[11px] uppercase tracking-wider shadow-lg">
                  Most Popular
                </div>
              )}

              <div>
                <div className="flex items-center justify-between mb-4">
                  <span className={`px-2.5 py-1 rounded-lg text-xs font-bold border ${tier.badgeColor}`}>
                    {tier.level} Tier
                  </span>
                  <div className="text-xs font-medium text-emerald-400 flex items-center gap-1">
                    <Zap className="w-3.5 h-3.5" /> {tier.dailyYield} / Day
                  </div>
                </div>

                <h3 className="text-xl font-bold text-white mb-1">{tier.title}</h3>
                <div className="flex items-baseline gap-1 my-3">
                  <span className="text-3xl sm:text-4xl font-black text-white font-display">₹{tier.amount}</span>
                  <span className="text-xs text-slate-400">order</span>
                </div>

                <div className="p-3 rounded-2xl bg-white/5 border border-white/5 mb-5 space-y-1">
                  <div className="flex justify-between text-xs">
                    <span className="text-slate-400">Daily Return:</span>
                    <span className="text-emerald-400 font-bold">{tier.dailyAmount}</span>
                  </div>
                  <div className="flex justify-between text-xs">
                    <span className="text-slate-400">Bonus:</span>
                    <span className="text-amber-400 font-medium">{tier.bonus}</span>
                  </div>
                </div>

                <ul className="space-y-2.5 text-xs text-slate-300 mb-6">
                  {tier.features.map((f, i) => (
                    <li key={i} className="flex items-start gap-2">
                      <Check className="w-4 h-4 text-emerald-400 shrink-0 mt-0.5" />
                      <span>{f}</span>
                    </li>
                  ))}
                </ul>
              </div>

              <button
                onClick={onDownloadClick}
                className={`w-full py-3 px-4 rounded-xl font-bold text-xs flex items-center justify-center gap-2 transition-all ${
                  tier.popular
                    ? 'bg-gradient-to-r from-emerald-400 to-teal-400 text-slate-950 hover:brightness-110 shadow-lg shadow-emerald-500/25'
                    : 'bg-white/10 hover:bg-white/15 text-white'
                }`}
              >
                <span>Deploy in App</span>
                <ArrowRight className="w-4 h-4" />
              </button>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
