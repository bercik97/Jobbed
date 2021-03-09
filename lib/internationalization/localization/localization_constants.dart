import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'demo_localization.dart';

String getTranslated(BuildContext context, String key) {
  return DemoLocalization.of(context).getTranslatedValue(key);
}

const String ENGLISH = 'en';
const String GEORGIA = 'pt';
const String POLISH = 'pl';
const String RUSSIAN = 'ru';
const String UKRAINIAN = 'uk';

const String LANGUAGE_CODE = 'languageCode';

Future<Locale> setLocale(String languageCode) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(LANGUAGE_CODE, languageCode);
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  Locale _temp;
  switch (languageCode) {
    case ENGLISH: _temp = Locale(languageCode, 'EN'); break;
    case GEORGIA: _temp = Locale(languageCode, 'PT'); break;
    case POLISH: _temp = Locale(languageCode, 'PL'); break;
    case RUSSIAN: _temp = Locale(languageCode, 'RU'); break;
    case UKRAINIAN: _temp = Locale(languageCode, 'UA'); break;
    default: _temp = Locale(POLISH, 'PL');
  }
  return _temp;
}

Future<Locale> getLocale() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String languageCode = _prefs.getString(LANGUAGE_CODE) ?? POLISH;
  return _locale(languageCode);
}
