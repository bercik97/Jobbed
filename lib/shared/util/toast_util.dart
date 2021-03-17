import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/shared/libraries/colors.dart';

class ToastUtil {
  static showSuccessNotification(BuildContext context, String msg) {
    BotToast.showSimpleNotification(
      title: getTranslated(context, 'success'),
      subTitle: msg,
      duration: Duration(seconds: 3),
      backgroundColor: BRIGHTER_GREEN,
      titleStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      subTitleStyle: TextStyle(fontSize: 15),
    );
  }

  static showErrorToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16,
    );
  }
}
