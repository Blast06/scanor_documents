// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '/utils/helpers.dart';
import 'lang/ar_ar.dart';
import 'lang/en_us.dart';
import 'lang/es_es.dart';
import 'lang/fr_fr.dart';

var logger = Logger();

class LocalizationService extends Translations {
  static final locale = Locale('en', 'US');
  static final fallbackLocale = Locale('en', 'US');
  //String? locale2 = await Devicelocale.currentLocale;
  // Supported languages
  static final langs = [
    'English',
    'French',
    'Arabic',
    'Spanish',
  ];

  // Supported locales
  static final locales = [
    Locale('en', 'US'),
    Locale('fr', 'FR'),
    Locale('ar'),
    Locale('es', 'ES'),
  ];

  // Keys and their translations
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'fr_FR': frFR,
        'ar': arAR,
        'es_ES': esES,
      };

  // Gets locale from language, and updates the locale
  void changeLocale(String lang) {
    final locale = getLocaleFromLanguage(lang);

    writeStorage('lng', lang);

    Get.updateLocale(locale);
  }

  // Finds language in `langs` list and returns it as Locale
  Locale getLocaleFromLanguage(String lang) {
    for (int i = 0; i < langs.length; i++) {
      if (lang == langs[i]) return locales[i];
    }
    return Get.locale!;
  }

  Locale? getCurrentLocale() {
  String savedLang = readStorage('lng');

  if (savedLang != null) {
    final locale = getLocaleFromLanguage(savedLang);

    return locale;
  }

  // If no saved language preference, use the device's locale
  return Get.deviceLocale;
}


  String getCurrentLang() {
    return readStorage('lng') ?? "English";
  }
}
