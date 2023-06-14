import 'dart:io';

import 'package:logger/logger.dart';

import '/consts/consts.dart';

import '/controllers/setting_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppOpenService extends GetxController {
  SettingController settingController = Get.find();
  Logger logger = Logger();
  AppOpenAd? appOpenAd;
  bool _isShowingAd = false;
  final Duration maxCacheDuration = const Duration(hours: 4);
  DateTime? _appOpenLoadTime;

  @override
  void onInit() async {
    super.onInit();
    logger.i("app open loading");
    await loadAd();
  }

   Future<void> loadAd([showAd = false]) async{
    if (settingController.adsType.value != 'google' || !AppConsts.adsStatus) {
      return;
    }
    AppOpenAd.load(
      adUnitId: Platform.isAndroid
          ? AppConsts.androidAppopenAdCode
          : AppConsts.iosAppopenAdCode,
      orientation: AppOpenAd.orientationPortrait,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenLoadTime = DateTime.now();
          appOpenAd = ad;
          debugPrint('AppOpenAd loaded');
          if (showAd) {
            showAdIfAvailable();
          }
        },
        onAdFailedToLoad: (error) {
          debugPrint('AppOpenAd failed to load: $error');
          // Handle the error.
        },
      ),
    );
  }

  /// Whether an ad is available to be shown.
  bool get isAdAvailable {
    return appOpenAd != null;
  }

  void showAdIfAvailable() {
    if (settingController.adsType.value != 'google' || !AppConsts.adsStatus) {
      return;
    }
    if (!isAdAvailable) {
      debugPrint('Tried to show ad before available.');
      loadAd();
      return;
    }
    if (_isShowingAd) {
      debugPrint('Tried to show ad while already showing an ad.');
      return;
    }
    if (DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)) {
      debugPrint('Maximum cache duration exceeded. Loading another ad.');
      appOpenAd!.dispose();
      appOpenAd = null;
      loadAd();
      return;
    }
    // Set the fullScreenContentCallback and show the ad.
    appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        debugPrint('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        ad.dispose();
        appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('$ad onAdDismissedFullScreenContent');
        _isShowingAd = false;
        ad.dispose();
        appOpenAd = null;
        loadAd();
      },
    );

    appOpenAd!.show();
  }
}

class AppLifecycleReactor {
  final AppOpenService appOpenAdManager;

  AppLifecycleReactor({required this.appOpenAdManager});

  void listenToAppStateChanges() {
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream
        .forEach((state) => _onAppStateChanged(state));
  }

  //check this method to see if it is triggered when a state change
  void _onAppStateChanged(AppState appState) {
    if (appState == AppState.foreground) {
      //appOpenAdManager.showAdIfAvailable();
    }
  }
}
