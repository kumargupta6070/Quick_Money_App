import 'package:flutter/foundation.dart';

enum Environment { dev, staging, prod }

class AppConfig {
  static Environment environment = Environment.dev;

  static const String appName = 'Quick Money';
  static const String appVersion = '1.0.0';

  static String get apiBaseUrl {
    switch (environment) {
      case Environment.dev:
        // Use localhost for Web & Desktop, 10.0.2.2 for Android Emulator
        if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) {
          return 'http://localhost:5000/api/v1';
        }
        return 'http://10.0.2.2:5000/api/v1';
      case Environment.staging:
        return 'https://quick-money-staging.onrender.com/api/v1';
      case Environment.prod:
        return 'https://quick-money-api.onrender.com/api/v1';
    }
  }


  /// Toggle between live backend API calls and local mock fallback
  static bool useMockData = false;
}
