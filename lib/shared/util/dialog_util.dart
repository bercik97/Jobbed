import 'package:flutter/material.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';

class DialogUtil {
  static showFailureDialogWithWillPopScopeByDoublePopNavigator(BuildContext context, String msg, StatefulWidget widget) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          child: AlertDialog(
            backgroundColor: WHITE,
            title: textRedBold(getTranslated(context, 'failure')),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  textBlack(msg),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: textBlack(getTranslated(context, 'ok')),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          onWillPop: () async {
            Navigator.pop(context);
            Navigator.pop(context);
            return true;
          },
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
            backgroundColor: WHITE,
            title: textRedBold(getTranslated(context, 'failure')),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  textBlack(msg),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: textBlack(getTranslated(context, 'ok')),
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
            backgroundColor: WHITE,
            title: textGreenBold(getTranslated(context, 'success')),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  textBlack(msg),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: textBlack(getTranslated(context, 'ok')),
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
          backgroundColor: WHITE,
          title: textRed(getTranslated(context, 'failure')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                textBlack(content),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: textBlack(getTranslated(context, 'close')),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  static showInformationDialog(BuildContext context, String content) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: WHITE,
          title: textGreenBold(getTranslated(context, 'information')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                textBlack(content),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: textBlack(getTranslated(context, 'close')),
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
          backgroundColor: WHITE,
          title: textGreenBold(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                textBlack(content),
              ],
            ),
          ),
          actions: [
            FlatButton(
              child: textBlack(getTranslated(context, 'yes')),
              onPressed: () => isBtnTapped ? null : fun(),
            ),
            FlatButton(
              child: textBlack(getTranslated(context, 'no')),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  static void showScrollableDialog(BuildContext context, String title, String value) {
    if (value == null || value.isEmpty) {
      return;
    }
    showGeneralDialog(
      context: context,
      barrierColor: WHITE.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: title,
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[
                        text20BlueBold(title),
                        SizedBox(height: 20),
                        textCenter20Black(UTFDecoderUtil.decode(context, value)),
                        SizedBox(height: 20),
                        Container(
                          width: 60,
                          child: MaterialButton(
                            elevation: 0,
                            height: 50,
                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[iconWhite(Icons.close)],
                            ),
                            color: Colors.red,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
