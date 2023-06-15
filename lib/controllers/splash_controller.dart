import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:quick_scanner/services/app_open_service.dart';
import 'package:is_first_run/is_first_run.dart';
import '../views/screens/parent_screen.dart';


class SplashController extends GetxController {
  final admob = Get.find<AppOpenService>();
  Logger log = Logger();

  bool showInterstitial = false;

  @override
  void onReady() async {
    log.i("onReady of splash controller");
    bool firstRun = await IsFirstRun.isFirstRun();

    super.onReady();
    // await admob.loadAd();

 
    await Future.delayed(const Duration(seconds: 5), () {
      
       if (!firstRun) {
        admob.appOpenAd!.show();
      }
      // Get.offAndToNamed(Routes.FORM_SCREEN);
       Get.offAll(() => const ParentScreen());
    });
  }

  void onInit() async {
    super.onInit();
    log.i("Init of splash controller");
    // await prepareApi();
    // await admob.loadInterstitial();
  }
}