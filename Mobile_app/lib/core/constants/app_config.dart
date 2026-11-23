import 'package:flutter/foundation.dart';


enum Environment {
  dev, // Localhost (Windows/Web/Android Emulator)
  localWifi, // Physical Phone over Wi-Fi
  staging, // Staging Render Server
  prod, // Live Production Backend on Render
}

class AppConfig {
  /// Active Environment: Switch to Environment.prod when connecting to live Render deployment
  static Environment environment = Environment.dev;

  static const String appName = 'Quick Money';
  static const String appVersion = '1.0.0';
  static const String officialWebsiteUrl = 'https://quickmoney.netlify.app';

  /// Physical Device Wi-Fi IP (Check ipconfig, e.g. '192.168.1.10')
  static const String localWifiIp = '192.168.1.10';

  /// Live Render Deployment URL (Update with your Render app url)
  static const String liveRenderUrl =
      'https://quick-money-api.onrender.com/api/v1';

  static String get apiBaseUrl {
    switch (environment) {
      case Environment.dev:
        // Use localhost for Web & Desktop, 10.0.2.2 for Android Emulator
        if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) {
          return 'http://localhost:5000/api/v1';
        }
        return 'http://10.0.2.2:5000/api/v1';
      case Environment.localWifi:
        return 'http://$localWifiIp:5000/api/v1';
      case Environment.staging:
        return 'https://quick-money-staging.onrender.com/api/v1';
      case Environment.prod:
        return liveRenderUrl;
    }
  }

  /// Toggle between live backend API calls and local mock fallback
  static bool useMockData = false;
}
