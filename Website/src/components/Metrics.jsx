import React from 'react';
import { ShieldCheck, TrendingUp, Users, Zap } from 'lucide-react';

export default function Metrics() {
  const stats = [
    {
      label: 'Total Payouts Settled',
      value: '₹93,600+',
      detail: 'Direct to PhonePe UPI',
      icon: TrendingUp,
      color: 'from-emerald-400 to-teal-500',
      badge: '100% SOLVENT',
    },
    {
      label: 'Verified Traders',
      value: '10,000+',
      detail: 'Pan-India Active Network',
      icon: Users,
      color: 'from-cyan-400 to-blue-500',
      badge: 'ACTIVE COMMUNITY',
    },
    {
      label: 'Average Settlement Time',
      value: '15 Secs',
      detail: 'NPCI Fast-Track Gateway',
      icon: Zap,
      color: 'from-amber-400 to-orange-500',
      badge: 'INSTANT AUTO',
    },
    {
      label: 'Daily Protocol Yield',
      value: '2.5% Fixed',
      detail: 'Credited Midnight Daily',
      icon: ShieldCheck,
      color: 'from-purple-400 to-indigo-500',
      badge: 'COMPOUND READY',
    },
  ];

  return (
    <section className="py-12 border-y border-white/[0.08] bg-[#0A0F24]/60 backdrop-blur-md">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {stats.map((stat, idx) => {
            const Icon = stat.icon;
            return (
              <div
                key={idx}
                className="relative p-6 rounded-2xl bg-slate-900/80 border border-slate-800 hover:border-slate-700 transition-all hover:-translate-y-1 group"
              >
                <div className="flex items-center justify-between">
                  <div className={`p-3 rounded-xl bg-gradient-to-br ${stat.color} bg-opacity-10 text-white`}>
                    <Icon className="w-5 h-5 text-white" />
                  </div>
                  <span className="text-[10px] font-extrabold tracking-wider px-2 py-0.5 rounded-md bg-white/[0.05] text-slate-300">
                    {stat.badge}
                  </span>
                </div>

                <div className="mt-4">
                  <h3 className="text-3xl font-display font-black text-white tracking-tight">{stat.value}</h3>
                  <p className="text-sm font-semibold text-slate-200 mt-1">{stat.label}</p>
                  <p className="text-xs text-slate-400 mt-0.5">{stat.detail}</p>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
