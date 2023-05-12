// ignore_for_file: prefer_const_constructors
import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:quick_scanner/services/lang/ar_ar.dart';
import '/utils/helpers.dart';

import 'lang/fr_fr.dart';
import 'lang/en_us.dart';
import 'lang/es_es.dart';

var logger = Logger();

class LocalizationService extends Translations {
  static final locale = Locale('en', 'US');
  static final fallbackLocale = Locale('en', 'US');

  // Supported languages
  static final langs = ['English', 'French', 'Arabic', 'Spanish'];

  // Supported locales
  static final locales = [
    Locale('en', 'US'),
    Locale('fr', 'FR'),
    Locale('es', 'ES'),
    Locale('ar'),
  ];

  // Keys and their translations
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'fr_FR': frFR,
        'ar': arAR,
        'es-ES': esES,
      };

  // Gets locale from language, and updates the locale
  void changeLocale(String lang) {
    final locale = getLocaleFromLanguage(lang);

    writeStorage('lng', lang);

    Get.updateLocale(locale);
  }

  // Finds language in `langs` list and returns it as Locale
  getLocaleFromLanguage(String lang) async {
    for (int i = 0; i < langs.length; i++) {
      if (lang == langs[i]) return locales[i];
    }
    //String? locale = await Devicelocale.currentLocale;
    
    return locale;
  }

  Locale getCurrentLocale() {
    Locale defaultLocale;

    if (readStorage('lng') != null) {
      final locale =
          LocalizationService().getLocaleFromLanguage(readStorage('lng'));

      defaultLocale = locale;
    } else {
      defaultLocale = Locale(
        'en',
        'US',
      );
    }

    return defaultLocale;
  }

  String getCurrentLang() {
    return readStorage('lng') ?? "English";
  }
}
