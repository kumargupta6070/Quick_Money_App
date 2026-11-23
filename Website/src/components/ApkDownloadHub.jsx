import React, { useState } from 'react';
import { Download, Smartphone, QrCode, ShieldCheck, CheckCircle2, AlertCircle, FileText, HardDrive, Sparkles, RefreshCw, ExternalLink } from 'lucide-react';

export default function ApkDownloadHub({ release, onDownloadClick }) {
  const [copied, setCopied] = useState(false);

  const handleCopyLink = () => {
    const raw = release?.downloadUrl || release?.download_url || '/quick-money.apk';
    const full = raw.startsWith('http') ? raw : `${window.location.origin}${raw.startsWith('/') ? '' : '/'}${raw}`;
    navigator.clipboard.writeText(full);
    setCopied(true);
    setTimeout(() => setCopied(false), 2500);
  };

  const stepsToInstall = [
    {
      num: '1',
      title: 'Tap Download APK',
      desc: 'Save the official quick-money.apk to your phone (Chrome may show "File might be harmful" warning — tap "Download anyway").',
    },
    {
      num: '2',
      title: 'Enable Unknown Sources',
      desc: 'Go to Settings > Security (or tap the downloaded notification) and allow "Install unknown apps" for Chrome or Files.',
    },
    {
      num: '3',
      title: 'Install & Launch',
      desc: 'Open the installer, tap "Install", and log in with your registered email to immediately claim ₹100 Welcome Bonus.',
    },
  ];

  return (
    <section id="download" className="py-24 relative overflow-hidden bg-gradient-to-b from-slate-950 via-blue-950/20 to-slate-950">
      {/* Background glow orbs */}
      <div className="absolute top-1/2 left-1/4 -translate-y-1/2 w-96 h-96 bg-blue-500/10 rounded-full blur-[120px] pointer-events-none" />
      <div className="absolute top-1/2 right-1/4 -translate-y-1/2 w-96 h-96 bg-emerald-500/10 rounded-full blur-[120px] pointer-events-none" />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div className="text-center max-w-3xl mx-auto mb-16">
          <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-blue-500/10 border border-blue-500/20 text-blue-400 text-xs font-semibold uppercase tracking-wider mb-4">
            <Smartphone className="w-3.5 h-3.5" />
            Official Android Release Hub
          </div>
          <h2 className="text-3xl sm:text-5xl font-black text-white tracking-tight mb-4 font-display">
            Download <span className="bg-gradient-to-r from-blue-400 via-indigo-300 to-emerald-400 bg-clip-text text-transparent">Quick Money APK</span>
          </h2>
          <p className="text-slate-400 text-base sm:text-lg">
            Direct high-speed download. Managed dynamically by administrators with cryptographic hash validation.
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-stretch">
          {/* Main APK Box */}
          <div className="lg:col-span-7 rounded-3xl p-8 bg-slate-900/80 border border-slate-800 shadow-2xl backdrop-blur-xl flex flex-col justify-between">
            <div>
              {/* Header Badge */}
              <div className="flex flex-wrap items-center justify-between gap-4 mb-6 pb-6 border-b border-slate-800/80">
                <div className="flex items-center gap-3">
                  <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-blue-500 to-emerald-500 flex items-center justify-center text-white shadow-lg shadow-blue-500/20">
                    <Smartphone className="w-6 h-6" />
                  </div>
                  <div>
                    <h3 className="text-xl font-bold text-white flex items-center gap-2">
                      Quick Money Mobile
                      <span className="px-2 py-0.5 rounded-md bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 text-xs font-semibold">
                        v{release?.version || '1.0.0'}
                      </span>
                    </h3>
                    <p className="text-xs text-slate-400">Android 7.0+ (ARM64 & x86_64)</p>
                  </div>
                </div>

                <div className="flex items-center gap-2 text-xs font-medium text-emerald-400 bg-emerald-500/10 border border-emerald-500/20 px-3 py-1.5 rounded-xl">
                  <ShieldCheck className="w-4 h-4" />
                  VirusTotal Clean
                </div>
              </div>

              {/* Specs Grid */}
              <div className="grid grid-cols-3 gap-3 mb-6">
                <div className="p-3.5 rounded-2xl bg-white/5 border border-white/5 text-center">
                  <div className="text-xs text-slate-400 mb-1 flex items-center justify-center gap-1">
                    <HardDrive className="w-3.5 h-3.5" /> File Size
                  </div>
                  <div className="text-sm font-bold text-white">{release?.fileSize || release?.file_size || '65.9 MB'}</div>
                </div>
                <div className="p-3.5 rounded-2xl bg-white/5 border border-white/5 text-center">
                  <div className="text-xs text-slate-400 mb-1 flex items-center justify-center gap-1">
                    <RefreshCw className="w-3.5 h-3.5" /> Updated
                  </div>
                  <div className="text-sm font-bold text-white">
                    {release?.releasedAt ? new Date(release.releasedAt).toLocaleDateString() : 'Nov 2026'}
                  </div>
                </div>
                <div className="p-3.5 rounded-2xl bg-white/5 border border-white/5 text-center">
                  <div className="text-xs text-slate-400 mb-1 flex items-center justify-center gap-1">
                    <ShieldCheck className="w-3.5 h-3.5" /> Encrypted
                  </div>
                  <div className="text-sm font-bold text-emerald-400">AES-256 GCM</div>
                </div>
              </div>

              {/* Release Notes */}
              <div className="p-4 rounded-2xl bg-slate-950/60 border border-slate-800/80 mb-6">
                <div className="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-2 flex items-center gap-2">
                  <FileText className="w-4 h-4 text-blue-400" />
                  What's New in v{release?.version || '1.0.0'}:
                </div>
                <p className="text-xs text-slate-300 leading-relaxed">
                  {release?.releaseNotes || release?.release_notes || 'Initial production release with instant PhonePe payouts, 2-step OTP email verification, L1-L5 liquidity pools, AES-256 vault encryption, and 24/7 helpdesk.'}
                </p>
              </div>
            </div>

            {/* Action Buttons */}
            <div className="space-y-3">
              <button
                onClick={onDownloadClick}
                className="w-full py-4 px-6 rounded-2xl bg-gradient-to-r from-blue-600 via-indigo-600 to-emerald-500 hover:from-blue-500 hover:to-emerald-400 text-white font-bold text-base shadow-xl shadow-blue-500/25 flex items-center justify-center gap-3 transition-all hover:scale-[1.01] active:scale-[0.99]"
              >
                <Download className="w-5 h-5 animate-bounce" />
                <span>Download Quick Money APK (v{release?.version || '1.0.0'})</span>
              </button>

              <div className="flex gap-2">
                <button
                  onClick={handleCopyLink}
                  className="flex-1 py-2.5 px-4 rounded-xl bg-white/5 hover:bg-white/10 text-slate-300 hover:text-white text-xs font-semibold border border-white/10 transition-colors flex items-center justify-center gap-2"
                >
                  <ExternalLink className="w-3.5 h-3.5" />
                  {copied ? 'Link Copied to Clipboard!' : 'Copy Direct Download Link'}
                </button>
              </div>
            </div>
          </div>

          {/* QR Code & Android Install Guide */}
          <div className="lg:col-span-5 flex flex-col gap-6">
            {/* QR Card */}
            <div className="rounded-3xl p-6 bg-slate-900/80 border border-slate-800 shadow-xl backdrop-blur-xl text-center flex flex-col items-center justify-center">
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-blue-500/10 border border-blue-500/20 text-blue-400 text-xs font-semibold mb-3">
                <QrCode className="w-3.5 h-3.5" />
                Scan to Download on Phone
              </div>

              {/* QR Box Visual */}
              <div className="p-4 rounded-2xl bg-white shadow-2xl inline-block my-2">
                {/* SVG QR Code representation */}
                <div className="w-36 h-36 bg-slate-950 p-2 rounded-lg flex flex-col justify-between items-center relative overflow-hidden">
                  <div className="w-full h-full border-4 border-dashed border-blue-400/80 rounded flex items-center justify-center">
                    <Smartphone className="w-12 h-12 text-blue-400 animate-pulse" />
                  </div>
                  <div className="absolute inset-0 bg-gradient-to-t from-blue-600/20 to-transparent pointer-events-none" />
                </div>
              </div>
              <p className="text-xs text-slate-400 mt-2 max-w-xs">
                Scan using Google Lens or Camera on your smartphone to initiate immediate download.
              </p>
            </div>

            {/* Install Steps */}
            <div className="rounded-3xl p-6 bg-slate-900/60 border border-slate-800/80 backdrop-blur-xl flex-1 flex flex-col justify-between">
              <h4 className="text-sm font-bold text-white uppercase tracking-wider mb-4 flex items-center gap-2">
                <Sparkles className="w-4 h-4 text-amber-400" />
                Quick Installation Guide
              </h4>
              <div className="space-y-3.5">
                {stepsToInstall.map((s, idx) => (
                  <div key={idx} className="flex items-start gap-3">
                    <span className="w-6 h-6 rounded-lg bg-blue-500/20 text-blue-400 font-bold text-xs flex items-center justify-center shrink-0 mt-0.5 border border-blue-500/30">
                      {s.num}
                    </span>
                    <div>
                      <div className="text-xs font-bold text-slate-200">{s.title}</div>
                      <div className="text-[11px] text-slate-400 leading-snug">{s.desc}</div>
                    </div>
                  </div>
                ))}
              </div>
              <div className="mt-4 p-2.5 rounded-xl bg-amber-500/10 border border-amber-500/20 flex items-center gap-2 text-[11px] text-amber-300">
                <AlertCircle className="w-4 h-4 shrink-0" />
                <span>100% Secure & Clean APK verified by Antigravity Guard.</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
