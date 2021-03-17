import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';

class UTFDecoderUtil {
  static String decode(BuildContext context, String text) {
    if (text == null) {
      return getTranslated(context, 'empty');
    }
    try {
      return utf8.decode(text.runes.toList());
    } catch (e) {
      return text;
    }
  }
}
