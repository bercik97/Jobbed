import 'package:flutter/material.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/widget/texts.dart';

class DialogService {
  static showCustomDialog({BuildContext context, Widget titleWidget, String content}) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: DARK,
          title: titleWidget,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                textWhite(content),
              ],
            ),
          ),
          actions: [
            FlatButton(
              child: textWhite(getTranslated(context, 'close')),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  static showFailureDialogWithWillPopScope(BuildContext context, String msg, StatefulWidget widget) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          child: AlertDialog(
            backgroundColor: DARK,
            title: textRed(getTranslated(context, 'failure')),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  textWhite(msg),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: textWhite(getTranslated(context, 'ok')),
                onPressed: () => _resetAndOpenPage(context, widget),
              ),
            ],
          ),
          onWillPop: () => _navigateToPage(context, widget),
        );
      },
    );
  }

  static showSuccessDialogWithWillPopScope(BuildContext context, String msg, StatefulWidget widget) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          child: AlertDialog(
            backgroundColor: DARK,
            title: textGreen(getTranslated(context, 'success')),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  textWhite(msg),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: textWhite(getTranslated(context, 'ok')),
                onPressed: () => _resetAndOpenPage(context, widget),
              ),
            ],
          ),
          onWillPop: () => _navigateToPage(context, widget),
        );
      },
    );
  }

  static Future<bool> _navigateToPage(BuildContext context, StatefulWidget widget) async {
    _resetAndOpenPage(context, widget);
    return true;
  }

  static void _resetAndOpenPage(BuildContext context, StatefulWidget widget) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => widget),
      ModalRoute.withName('/'),
    );
  }

  static showErrorDialog(BuildContext context, String content) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: DARK,
          title: textGreen(getTranslated(context, 'error')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                textWhite(content),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: textWhite(getTranslated(context, 'close')),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
