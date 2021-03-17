import 'package:flutter/material.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/widget/texts.dart';

import '../../internationalization/localization/localization_constants.dart';
import '../../main.dart';
import '../../unauthenticated/login_page.dart';

class LogoutUtil {
  static logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: WHITE,
          title: textGreenBold(getTranslated(context, 'logout')),
          content: textBlack(getTranslated(context, 'logoutConfirm')),
          actions: <Widget>[
            FlatButton(
              child: textBlack(getTranslated(context, 'yes')),
              onPressed: () => logoutWithoutConfirm(context, getTranslated(context, 'logoutSuccessfully')),
            ),
            FlatButton(child: textBlack(getTranslated(context, 'no')), onPressed: () => Navigator.of(context).pop()),
          ],
        );
      },
    );
  }

  static logoutWithoutConfirm(BuildContext context, String msg) {
    storage.delete(key: 'authorization');
    storage.delete(key: 'role');
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (e) => false);
    if (msg != null) {
      ToastUtil.showSuccessNotification(context, msg);
    }
  }

  static handle401WithLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: WHITE,
          title: textRed(getTranslated(context, 'accountExpired')),
          content: textBlack(getTranslated(context, 'yourAccountProbablyExpired')),
          actions: <Widget>[
            FlatButton(
              child: textBlack(getTranslated(context, 'ok')),
              onPressed: () => logoutWithoutConfirm(context, null),
            ),
          ],
        );
      },
    );
  }
}
