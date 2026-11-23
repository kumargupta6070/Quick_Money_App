import React, { useState, useEffect } from 'react';
import confetti from 'canvas-confetti';
import Navbar from './components/Navbar';
import Hero from './components/Hero';
import Metrics from './components/Metrics';
import Features from './components/Features';
import HowItWorks from './components/HowItWorks';
import Packages from './components/Packages';
import ApkDownloadHub from './components/ApkDownloadHub';
import SecurityCompliance from './components/SecurityCompliance';
import FaqSection from './components/FaqSection';
import Footer from './components/Footer';
import { fetchLatestRelease, DEFAULT_RELEASE } from './services/api';

export default function App() {
  const [release, setRelease] = useState(DEFAULT_RELEASE);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let mounted = true;
    fetchLatestRelease()
      .then((data) => {
        if (mounted && data) {
          setRelease(data);
        }
      })
      .catch((err) => {
        console.warn('Using default release fallback:', err);
      })
      .finally(() => {
        if (mounted) setLoading(false);
      });

    return () => {
      mounted = false;
    };
  }, []);

  const triggerDownloadConfetti = () => {
    // Fire festive celebration confetti
    try {
      confetti({
        particleCount: 80,
        spread: 70,
        origin: { y: 0.6 },
        colors: ['#3b82f6', '#10b981', '#f59e0b', '#8b5cf6', '#06b6d4'],
      });
    } catch (e) {
      // Ignored if canvas-confetti is not loaded
    }

    // Direct programmatic anchor download trigger
    let finalUrl = release?.downloadUrl || release?.download_url || '/quick-money.apk';
    if (!finalUrl || finalUrl.includes('github.com/kumargupta6070/Quick_Money_App/releases')) {
      finalUrl = '/quick-money.apk';
    }

    const anchor = document.createElement('a');
    anchor.href = finalUrl;
    anchor.setAttribute('download', 'quick-money.apk');
    anchor.target = '_self';
    document.body.appendChild(anchor);
    anchor.click();
    setTimeout(() => {
      try {
        document.body.removeChild(anchor);
      } catch (_) {}
    }, 1000);
  };

  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 flex flex-col font-sans selection:bg-blue-500 selection:text-white">
      {/* Top Navigation */}
      <Navbar release={release} onDownload={triggerDownloadConfetti} onDownloadClick={triggerDownloadConfetti} />

      {/* Hero with Live Phone Mockup & Download CTA */}
      <Hero release={release} onDownload={triggerDownloadConfetti} onDownloadClick={triggerDownloadConfetti} />

      {/* Live Financial Metrics */}
      <Metrics />

      {/* Core Protocol Features */}
      <Features />

      {/* 4-Step Interactive Guide */}
      <HowItWorks />

      {/* Packages Tier Showcase */}
      <Packages onDownloadClick={triggerDownloadConfetti} />

      {/* Dedicated APK Download Hub with Dynamic Version & QR */}
      <ApkDownloadHub release={release} onDownloadClick={triggerDownloadConfetti} />

      {/* Security & NPCI Compliance */}
      <SecurityCompliance />

      {/* Frequently Asked Questions */}
      <FaqSection />

      {/* Official Footer with Email quick.moneey.in@gmail.com */}
      <Footer release={release} onDownloadClick={triggerDownloadConfetti} />
    </div>
  );
}
