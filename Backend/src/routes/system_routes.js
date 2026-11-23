const express = require('express');
const router = express.Router();
const { SystemSetting } = require('../models');
const ResponseHandler = require('../utils/response_handler');

// Default fallback release metadata
const DEFAULT_RELEASE = {
  version: '1.0.0',
  version_code: 1,
  download_url: 'https://github.com/kumargupta6070/Quick_Money_App/releases/download/v1.0.0/quick-money-v1.0.0.apk',
  file_size: '28.4 MB',
  release_notes: 'Official Public Release with PhonePe Auto-Return, Real Email OTP & AES-256 Vault',
  is_active: true,
  sha256: '8a6bce1846f255b88885876928d79e6ecfcdafde46073fec59b87f7d2ece7801',
  updated_at: new Date().toISOString(),
};

/**
 * @swagger
 * /api/v1/system/app-release:
 *   get:
 *     summary: Public API to fetch current active Android APK release for the website
 *     tags: [System]
 */
router.get('/app-release', async (req, res) => {
  try {
    const setting = await SystemSetting.findOne({ where: { key: 'app_apk_release' } });
    if (!setting) {
      return ResponseHandler.success(res, DEFAULT_RELEASE, 'Default app release metadata');
    }
    const parsed = JSON.parse(setting.value);
    return ResponseHandler.success(res, parsed, 'Latest APK release metadata');
  } catch (error) {
    return ResponseHandler.success(res, DEFAULT_RELEASE, 'Fallback release metadata');
  }
});

module.exports = router;
