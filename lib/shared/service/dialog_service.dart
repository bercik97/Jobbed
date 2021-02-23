import 'package:flutter/material.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/widget/texts.dart';

class DialogService {
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
          title: textRed(getTranslated(context, 'failure')),
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

  static showConfirmationDialog({BuildContext context, String title, String content, bool isBtnTapped, Function() fun}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: DARK,
          title: textGreenBold(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                textWhite(content),
              ],
            ),
          ),
          actions: [
            FlatButton(
              child: textWhite(getTranslated(context, 'yes')),
              onPressed: () => isBtnTapped ? null : fun(),
            ),
            FlatButton(
              child: textWhite(getTranslated(context, 'no')),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
