import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:is_first_run/is_first_run.dart';

class ExternalServices {
  static ExternalServices? _instance;

  ExternalServices._();

  static ExternalServices getInstance() {
    _instance ??= ExternalServices._();

    return _instance!;
  }

  showRateApp({bool forceStore = false}) async {
    bool firstRun = await IsFirstRun.isFirstRun();
    if (!firstRun) {
      InAppReview.instance.isAvailable().then((value) {
        if (value && !forceStore) {
          InAppReview.instance.requestReview();
        } else {
          InAppReview.instance.openStoreListing();
        }
      });
    } else {
      //do nothing
    }
  }
}
