enum Environment { dev, staging, prod }

class AppConfig {
  static Environment environment = Environment.dev;

  static const String appName = 'Quick Money';
  static const String appVersion = '1.0.0';

  static String get apiBaseUrl {
    switch (environment) {
      case Environment.dev:
        return 'http://10.0.2.2:5000/api/v1'; // Android emulator localhost
      case Environment.staging:
        return 'https://quick-money-staging.onrender.com/api/v1';
      case Environment.prod:
        return 'https://quick-money-api.onrender.com/api/v1';
    }
  }

  /// When true, app serves rich local mock data without hitting network
  static bool useMockData = true;
}

