class AppEnvironment {
  static const bool enableFirebase = bool.fromEnvironment('ENABLE_FIREBASE', defaultValue: false);
  static const bool enableAds = bool.fromEnvironment('ENABLE_ADS', defaultValue: true);
  static const bool enableAnalytics = bool.fromEnvironment('ENABLE_ANALYTICS', defaultValue: true);
}
