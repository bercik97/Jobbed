import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/widget/contact_section.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';

void showContactForManager(BuildContext context, String manager, String phone, String viber, String whatsApp) {
  showGeneralDialog(
    context: context,
    barrierColor: DARK.withOpacity(0.95),
    barrierDismissible: false,
    barrierLabel: getTranslated(context, 'contact'),
    transitionDuration: Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) {
      return SizedBox.expand(
        child: Scaffold(
          backgroundColor: Colors.black12,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                textCenter20GreenBold(utf8.decode(manager.runes.toList())),
                SizedBox(height: 20),
                Padding(padding: EdgeInsets.only(left: 85), child: buildContactSection(context, phone, viber, whatsApp)),
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
        ),
      );
    },
  );
}
