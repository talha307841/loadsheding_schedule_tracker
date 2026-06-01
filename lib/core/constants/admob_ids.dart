class AdMobIds {
  static const String developmentBannerId = 'ca-app-pub-3940256099942544/2934735716';
  static const String developmentInterstitialId = 'ca-app-pub-3940256099942544/1033173712';

  static const String productionBannerId = String.fromEnvironment(
    'ADMOB_BANNER_ID',
    defaultValue: 'ca-app-pub-0000000000000000/0000000000',
  );
  static const String productionInterstitialId = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_ID',
    defaultValue: 'ca-app-pub-0000000000000000/0000000000',
  );

  static bool get useProduction => const bool.fromEnvironment('dart.vm.product');

  static String get bannerId => useProduction ? productionBannerId : developmentBannerId;
  static String get interstitialId => useProduction ? productionInterstitialId : developmentInterstitialId;
}
