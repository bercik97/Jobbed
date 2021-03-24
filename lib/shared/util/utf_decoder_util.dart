import 'dart:convert';

import 'package:flutter/cupertino.dart';

class UTFDecoderUtil {
  static String decode(String text) {
    if (text == null) {
      return null;
    }
    try {
      return utf8.decode(text.runes.toList());
    } catch (e) {
      return text;
    }
  }
}
