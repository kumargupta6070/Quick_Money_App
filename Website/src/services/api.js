// Default Static Release Fallback
export const DEFAULT_RELEASE = {
  version: '1.0.0',
  version_code: 1,
  download_url: 'https://github.com/kumargupta6070/Quick_Money_App/releases/download/v1.0.0/quick-money-v1.0.0.apk',
  file_size: '28.4 MB',
  release_notes: 'Official Public Release with PhonePe Auto-Return, Real Email OTP & AES-256 Vault',
  sha256: '8a6bce1846f255b88885876928d79e6ecfcdafde46073fec59b87f7d2ece7801',
  is_active: true,
  updated_at: '2026-11-23',
};

// API Base URL (defaults to production Render backend, or override via env)
const API_BASE_URL = import.meta.env.VITE_API_URL || 'https://quick-money-api.onrender.com/api/v1';

/**
 * Fetches the active APK release metadata dynamically from the live backend
 */
export async function fetchLatestRelease() {
  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 4000); // 4-sec timeout

    const res = await fetch(`${API_BASE_URL}/system/app-release`, {
      signal: controller.signal,
      headers: { 'Accept': 'application/json' },
    });
    clearTimeout(timeoutId);

    if (res.ok) {
      const data = await res.json();
      if (data && data.success && data.data) {
        return { ...DEFAULT_RELEASE, ...data.data };
      }
    }
    return DEFAULT_RELEASE;
  } catch (err) {
    // Graceful offline fallback
    return DEFAULT_RELEASE;
  }
}
