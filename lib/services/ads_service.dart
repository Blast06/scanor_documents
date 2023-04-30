import 'dart:io';

import '/consts/consts.dart';

import '/controllers/setting_controller.dart';
import '/utils/helpers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

int _numInterstitialLoadAttempts = 0;

class AdsService {
  static SettingController controller = Get.find<SettingController>();

  static InterstitialAd? interstitialAd;
  static const AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );

  static void createInterstitialAd([callback]) async {
    if (!AppConsts.adsStatus) {
      return;
    }
    if (controller.adsType.value == 'google') {
      InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? AppConsts.androidInterstitialAdCode
            : AppConsts.iosInterstitialAdCode,
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            if (kDebugMode) {
              dd('$ad loaded');
            }
            interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            if (callback != null) {
              Future.delayed(2.seconds, () {
                callback();
              });
            }
          },
          onAdFailedToLoad: (LoadAdError error) {
            if (kDebugMode) {
              dd('InterstitialAd failed to load: $error.');
            }
            _numInterstitialLoadAttempts += 1;
            interstitialAd = null;
            if (_numInterstitialLoadAttempts <= 3) {
              createInterstitialAd(callback);
            }
          },
        ),
      );
    } else if (controller.adsType.value == 'startapp') {
      dd('startapp');
    } else if (controller.adsType.value == 'facebook') {}
  }

  static void showInterstitialAd(callback,
      {adControl = true, onlyOn = ''}) async {
    if (!AppConsts.adsStatus) {
      callback();
      return;
    }
    if (!controller.showAd() && adControl) {
      callback();
      return;
    }

    if (controller.adsType.value == 'google' &&
        (onlyOn == '' || onlyOn == 'google')) {
      if (interstitialAd == null) {
        if (kDebugMode) {
          dd('Warning: attempt to show interstitial before loaded.');
        }

        callback();

        return;
      }
      interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) =>
            dd('ad onAdShowedFullScreenContent.'),
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          dd('$ad onAdDismissedFullScreenContent.');
          ad.dispose();
          interstitialAd = null;
          createInterstitialAd();
          callback();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          dd('$ad onAdFailedToShowFullScreenContent: $error');
          ad.dispose();
          interstitialAd = null;
          callback();
          createInterstitialAd();
        },
      );
      interstitialAd?.show();
      interstitialAd = null;
    } else if (controller.adsType.value == 'startapp' &&
        (onlyOn == '' || onlyOn == 'startapp')) {
    } else if (controller.adsType.value == 'facebook' &&
        (onlyOn == '' || onlyOn == 'facebook')) {}
  }
}

class BannerAds extends StatelessWidget {
  BannerAds({Key? key}) : super(key: key);
  final SettingController settingController = Get.find();

  @override
  Widget build(BuildContext context) {
    if (!AppConsts.adsStatus) {
      return const SizedBox();
    } else if (settingController.adsType.value == 'google') {
      return const GoogleBannerAds();
    } else if (settingController.adsType.value == 'startapp') {}

    return const SizedBox();
  }
}

class GoogleBannerAds extends StatefulWidget {
  const GoogleBannerAds({Key? key}) : super(key: key);

  @override
  GoogleBannerAdsState createState() => GoogleBannerAdsState();
}

class GoogleBannerAdsState extends State<GoogleBannerAds> {
  SettingController settingController = Get.find();
  static const AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );
  BannerAd? _anchoredBanner;
  bool _loadingAnchoredBanner = false;
  Future<void> _createAnchoredBanner(BuildContext context) async {
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      MediaQuery.of(context).size.width.truncate(),
    );

    if (size == null) {
      dd('Unable to get height of anchored banner.');
      return;
    }

    final BannerAd banner = BannerAd(
      size: size,
      request: request,
      adUnitId: Platform.isAndroid
          ? AppConsts.androidBannerAdCode
          : AppConsts.iosBannerAdCode,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          dd('$BannerAd loaded.');
          setState(() {
            _anchoredBanner = ad as BannerAd?;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          dd('$BannerAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => dd('$BannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => dd('$BannerAd onAdClosed.'),
      ),
    );
    return banner.load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_loadingAnchoredBanner && AppConsts.adsStatus) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }
  }

  @override
  void dispose() {
    _anchoredBanner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _anchoredBanner != null
        ? Container(
            color: Colors.transparent,
            width: _anchoredBanner!.size.width.toDouble(),
            height: _anchoredBanner!.size.height.toDouble(),
            child: AdWidget(ad: _anchoredBanner!),
          )
        : const SizedBox();
  }
}

class InlineAds extends StatefulWidget {
  const InlineAds({Key? key}) : super(key: key);

  @override
  InlineAdsState createState() => InlineAdsState();
}

class InlineAdsState extends State<InlineAds> {
  SettingController settingController = Get.find();
  BannerAd? _bannerAd;
  bool _bannerAdIsLoaded = false;

  @override
  Widget build(BuildContext context) {
    final BannerAd? bannerAd = _bannerAd;
    if (_bannerAdIsLoaded && bannerAd != null && AppConsts.adsStatus) {
      return SizedBox(
        height: bannerAd.size.height.toDouble(),
        width: bannerAd.size.width.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }

    return const SizedBox();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppConsts.adsStatus) {
      _bannerAd = BannerAd(
        adUnitId: Platform.isAndroid
            ? AppConsts.androidBannerAdCode
            : AppConsts.iosBannerAdCode,
        request: const AdRequest(),
        size: AdSize.mediumRectangle,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            dd('$AdManagerBannerAd loaded.');
            setState(() {
              _bannerAdIsLoaded = true;
            });
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            dd('$BannerAd failedToLoad: $error');
            ad.dispose();
          },
          onAdOpened: (Ad ad) => dd('$BannerAd onAdOpened.'),
          onAdClosed: (Ad ad) => dd('$BannerAd onAdClosed.'),
        ),
      )..load();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd?.dispose();
  }
}
