import React from 'react';
import { ShieldCheck, Lock, Landmark, Cpu, CheckCircle } from 'lucide-react';

export default function SecurityCompliance() {
  const certifications = [
    {
      title: 'NPCI UPI Interoperable',
      desc: 'Seamless auto-payout routing compatible with PhonePe, Google Pay, and Paytm protocols.',
      icon: Landmark,
      color: 'from-blue-500 to-indigo-600',
    },
    {
      title: 'AES-256 GCM Cloud Vault',
      desc: 'All trader balances, credentials, and wallet tokens are stored cryptographically encrypted.',
      icon: Lock,
      color: 'from-emerald-500 to-teal-600',
    },
    {
      title: 'Real-Time Solvency Reserve',
      desc: 'Continuous treasury liquidity matching to guarantee same-day payout execution for all tiers.',
      icon: ShieldCheck,
      color: 'from-purple-500 to-pink-600',
    },
    {
      title: 'Immutable Audit Trail',
      desc: 'Every balance credit, yield accrual, and admin interaction is logged with non-repudiation timestamps.',
      icon: Cpu,
      color: 'from-amber-500 to-orange-600',
    },
  ];

  return (
    <section className="py-20 relative overflow-hidden bg-slate-900/40 border-y border-slate-800/80">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div className="text-center max-w-2xl mx-auto mb-14">
          <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs font-semibold uppercase tracking-wider mb-4">
            <ShieldCheck className="w-3.5 h-3.5" />
            Institutional Grade Security
          </div>
          <h2 className="text-2xl sm:text-4xl font-black text-white tracking-tight mb-3 font-display">
            Engineered for <span className="bg-gradient-to-r from-emerald-400 via-teal-300 to-blue-400 bg-clip-text text-transparent">Zero-Loss Reliability</span>
          </h2>
          <p className="text-slate-400 text-sm sm:text-base">
            Multi-layer security protocols safeguarding your capital, daily yield distributions, and personal data.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {certifications.map((item, i) => {
            const Icon = item.icon;
            return (
              <div
                key={i}
                className="p-6 rounded-3xl bg-slate-950/60 border border-slate-800/90 hover:border-slate-700 transition-all duration-300 hover:-translate-y-1 backdrop-blur-xl"
              >
                <div className={`w-12 h-12 rounded-2xl bg-gradient-to-br ${item.color} flex items-center justify-center text-white shadow-lg mb-5`}>
                  <Icon className="w-6 h-6" />
                </div>
                <h3 className="text-base font-bold text-white mb-2">{item.title}</h3>
                <p className="text-slate-400 text-xs leading-relaxed">{item.desc}</p>
                <div className="mt-4 pt-3 border-t border-slate-800/60 flex items-center gap-1.5 text-[11px] text-emerald-400 font-medium">
                  <CheckCircle className="w-3.5 h-3.5" /> Active & Verified
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
