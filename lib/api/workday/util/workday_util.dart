import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';

class WorkdayUtil {
  static void showScrollableDialog(BuildContext context, String title, String value) {
    if (value == null || value.isEmpty) {
      return;
    }
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
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
                        text20GreenBold(title),
                        SizedBox(height: 20),
                        textCenter20White(value != null ? utf8.decode(value.runes.toList()) : getTranslated(context, 'empty')),
                        SizedBox(height: 20),
                        Container(
                          width: 80,
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

  static void showVocationReasonDetails(BuildContext context, String vocationReason, bool verified) {
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'vocationReason'),
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
                        text20GreenBold(getTranslated(context, 'vocationReason')),
                        SizedBox(height: 20),
                        verified ? text16GreenBold(getTranslated(context, 'verifiedUpperCase')) : text16RedBold(getTranslated(context, 'notVerifiedUpperCase')),
                        SizedBox(height: 20),
                        textCenter20White(vocationReason != null ? utf8.decode(vocationReason.runes.toList()) : getTranslated(context, 'empty')),
                        SizedBox(height: 20),
                        Container(
                          width: 80,
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

  static void showScrollablePlanAndNote(BuildContext context, String date, String plan, String note) {
    if ((plan == null || plan.isEmpty) && (note == null || note.isEmpty)) {
      return;
    }
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
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
                        text20GreenBold(date.substring(0, 10)),
                        SizedBox(height: 20),
                        text20GreenBold(getTranslated(context, 'plan')),
                        SizedBox(height: 5),
                        textCenter20White(plan != null ? utf8.decode(plan.runes.toList()) : getTranslated(context, 'empty')),
                        SizedBox(height: 20),
                        text20GreenBold(getTranslated(context, 'note')),
                        SizedBox(height: 5),
                        textCenter20White(note != null ? utf8.decode(note.runes.toList()) : getTranslated(context, 'empty')),
                        SizedBox(height: 20),
                        Container(
                          width: 80,
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
