// Default Static Release Fallback
export const DEFAULT_RELEASE = {
  version: '1.0.0',
  version_code: 1,
  download_url: '/quick-money.apk',
  downloadUrl: '/quick-money.apk',
  file_size: '65.9 MB',
  fileSize: '65.9 MB',
  release_notes: 'Official Public Release with PhonePe Auto-Return, Real Email OTP & AES-256 Vault',
  sha256: 'f0ba78708848f62771f9fe367b735c2451a6932bc0734b4c809667134124eaac',
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
        const merged = { ...DEFAULT_RELEASE, ...data.data };
        // Protect against any broken github placeholder URLs
        if (!merged.download_url || merged.download_url.includes('github.com/kumargupta6070/Quick_Money_App/releases')) {
          merged.download_url = '/quick-money.apk';
        }
        merged.downloadUrl = merged.download_url;
        merged.fileSize = merged.file_size || merged.fileSize || '65.9 MB';
        return merged;
      }
    }
    return DEFAULT_RELEASE;
  } catch (err) {
    // Graceful offline fallback
    return DEFAULT_RELEASE;
  }
}
