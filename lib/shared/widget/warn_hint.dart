import 'package:draggable_widget/draggable_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/widget/texts.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;

import 'icons.dart';

Widget warnHint(BuildContext context, String content) {
  return FloatingActionButton(
    heroTag: "remember",
    tooltip: getTranslated(context, 'remember'),
    backgroundColor: Colors.orange,
    onPressed: () {
      slideDialog.showSlideDialog(
        context: context,
        backgroundColor: WHITE,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 30, left: 30, top: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon50Orange(Icons.assignment_late_outlined),
                    SizedBox(width: 5),
                    text50Orange(getTranslated(context, 'remember')),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 30, left: 30, top: 10),
                child: textCenter18Blue(content),
              ),
            ],
          ),
        ),
      );
    },
    child: text35WhiteBold('!'),
  );
}
