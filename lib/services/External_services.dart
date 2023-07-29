import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';

class ExternalServices {
 
  static ExternalServices? _instance;

  ExternalServices._();

  static ExternalServices getInstance() {
    _instance ??= ExternalServices._();

    return _instance!;
  }



  showRateApp({bool forceStore = false}) {
    InAppReview.instance.isAvailable().then((value) {
      if (value && !forceStore) {
        InAppReview.instance.requestReview();
      } else {
        InAppReview.instance.openStoreListing();
      }
    });
  }
}
