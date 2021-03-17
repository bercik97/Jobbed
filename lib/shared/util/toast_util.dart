import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
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

  static showErrorToast(BuildContext context, String msg) {
    BotToast.showSimpleNotification(
      title: getTranslated(context, 'failure'),
      subTitle: msg,
      duration: Duration(seconds: 3),
      backgroundColor: Colors.red,
      titleStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      subTitleStyle: TextStyle(fontSize: 15),
    );
  }
}
