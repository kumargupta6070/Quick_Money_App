import React, { useState } from 'react';
import { HelpCircle, ChevronDown, Sparkles } from 'lucide-react';

export default function FaqSection() {
  const [openIndex, setOpenIndex] = useState(0);

  const faqs = [
    {
      q: 'How do I download and install Quick Money on Android?',
      a: 'Simply tap the "Download APK" button on this website or scan the QR code with your phone. Once downloaded, open the APK file from your notifications or Downloads folder. If your phone prompts "Install unknown apps", grant permission for your browser, and tap Install.',
    },
    {
      q: 'Why does Android show a security warning when downloading the APK?',
      a: 'This is standard Android behavior for apps downloaded directly outside the Google Play Store (known as sideloading). Quick Money is cryptographically signed, scanned with VirusTotal, and completely free of malware or tracking scripts.',
    },
    {
      q: 'How do daily liquidity returns work?',
      a: 'When you activate a package (from L1 Starter at ₹500 to L5 Institutional), your order joins our institutional liquidity protocol. Returns are calculated transparently at 2.5% daily and automatically credited to your secure vault balance every 24 hours.',
    },
    {
      q: 'How do PhonePe payouts and withdrawals work?',
      a: 'You can bind your PhonePe UPI ID directly in your app profile. When you request a payout, our automated payout engine verifies the settlement and transfers the funds straight to your linked PhonePe account with 0% processing fee.',
    },
    {
      q: 'How fast is email OTP registration?',
      a: 'Our authentication engine uses direct high-speed pooled SMTP sockets on Port 465, delivering your 6-digit verification OTP to your Gmail or business email in under 2 seconds.',
    },
    {
      q: 'How can I contact Quick Money support?',
      a: 'You can raise a support ticket directly inside the mobile app Helpdesk with live status tracking. Alternatively, you can email our official team at quick.moneey.in@gmail.com for priority assistance.',
    },
  ];

  return (
    <section id="faq" className="py-24 relative overflow-hidden">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div className="text-center max-w-2xl mx-auto mb-16">
          <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-blue-500/10 border border-blue-500/20 text-blue-400 text-xs font-semibold uppercase tracking-wider mb-4">
            <HelpCircle className="w-3.5 h-3.5" />
            Clear Answers
          </div>
          <h2 className="text-3xl sm:text-5xl font-black text-white tracking-tight mb-4 font-display">
            Frequently Asked <span className="bg-gradient-to-r from-blue-400 via-indigo-300 to-purple-400 bg-clip-text text-transparent">Questions</span>
          </h2>
          <p className="text-slate-400 text-base">
            Everything you need to know about downloading the app, daily returns, and PhonePe security.
          </p>
        </div>

        <div className="space-y-4">
          {faqs.map((faq, idx) => {
            const isOpen = openIndex === idx;
            return (
              <div
                key={idx}
                className={`rounded-2xl transition-all duration-300 overflow-hidden border ${
                  isOpen
                    ? 'bg-slate-900/90 border-blue-500/40 shadow-xl shadow-blue-500/10'
                    : 'bg-slate-900/40 border-slate-800/80 hover:border-slate-700'
                }`}
              >
                <button
                  onClick={() => setOpenIndex(isOpen ? -1 : idx)}
                  className="w-full p-5 text-left flex items-center justify-between gap-4 font-bold text-white hover:text-blue-300 transition-colors"
                >
                  <span className="text-sm sm:text-base">{faq.q}</span>
                  <div
                    className={`w-8 h-8 rounded-full flex items-center justify-center shrink-0 transition-transform duration-300 ${
                      isOpen ? 'rotate-180 bg-blue-500/20 text-blue-400' : 'bg-white/5 text-slate-400'
                    }`}
                  >
                    <ChevronDown className="w-4 h-4" />
                  </div>
                </button>

                {isOpen && (
                  <div className="px-5 pb-5 pt-1 text-slate-300 text-xs sm:text-sm leading-relaxed border-t border-slate-800/60 animate-fadeIn">
                    {faq.a}
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
