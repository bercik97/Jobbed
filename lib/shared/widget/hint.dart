import 'package:flutter/cupertino.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;

void showHint(BuildContext context, String stText, String ndText) {
  slideDialog.showSlideDialog(
    context: context,
    backgroundColor: DARK,
    child: Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          text20GreenBold(getTranslated(context, 'hint')),
          SizedBox(height: 10),
          textCenter20White(stText),
          textCenter20White(ndText),
        ],
      ),
    ),
  );
}
