import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/constants/admob_ids.dart';

class AdService {
  AdService._();

  static final AdService instance = AdService._();

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _interstitialShownThisSession = false;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  BannerAd? get bannerAd => _bannerAd;

  void loadBanner({required void Function() onLoaded, required void Function(LoadAdError error) onFailed}) {
    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: AdMobIds.bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded(),
        onAdFailedToLoad: (_, error) => onFailed(error),
      ),
    )..load();
  }

  Future<void> loadInterstitial() async {
    if (_interstitialShownThisSession) {
      return;
    }
    await InterstitialAd.load(
      adUnitId: AdMobIds.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  Future<void> showInterstitialIfAvailable() async {
    if (_interstitialShownThisSession) {
      return;
    }
    final ad = _interstitialAd;
    if (ad == null) {
      return;
    }
    _interstitialShownThisSession = true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _interstitialAd = null;
      },
    );
    ad.show();
  }

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }
}
