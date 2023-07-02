import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '/consts/consts.dart';
import '/utils/helpers.dart';
import 'package:get/get.dart';

class SettingController extends GetxController {
  RxBool isLoading = true.obs;
  RxInt adCount = 0.obs;
  RxBool notification = true.obs;
  RxString adsType = 'google'.obs;
  RxInt adClickControl = 2.obs;
  RxString version = '1.0'.obs;
  RxString currentLanguage = 'English'.obs;

  @override
  void onInit() {
    super.onInit();
    onInitApp();
  }

  bool showAd() {
    if (AppConsts.adsStatus) {
      adCount.value = adCount.value + 1;
      if (adCount.value ==
          (Platform.isAndroid
              ? AppConsts.androidAdClickControl
              : AppConsts.iosAdClickControl)) {
        adCount.value = 0;
        return true;
      }
    }
    return false;
  }

  onInitApp() async {
    final info = await PackageInfo.fromPlatform();
    version.value = info.version;

   

    currentLanguage.value = readStorage('lng') ?? 'English';
  }

  
}
