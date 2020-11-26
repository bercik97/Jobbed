import 'package:flutter/material.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/widget/texts.dart';

class DialogService {
  static showCustomDialog({BuildContext context, Widget titleWidget, String content, List<Widget> actions, Future<bool> onWillPop}) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          child: AlertDialog(
            backgroundColor: DARK,
            title: titleWidget,
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  textWhite(content),
                ],
              ),
            ),
            actions: actions == null
                ? <Widget>[
                    FlatButton(
                      child: textWhite(getTranslated(context, 'close')),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ]
                : actions,
          ),
          onWillPop: () => onWillPop,
        );
      },
    );
  }
}
