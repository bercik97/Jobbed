import 'package:flutter/cupertino.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/widget/circular_progress_indicator.dart';
import 'package:progress_dialog/progress_dialog.dart';

class ProgressDialogInitializer {

  static ProgressDialog initializeProgressDialog(BuildContext context) {
    ProgressDialog progressDialog = new ProgressDialog(context);
    progressDialog.style(
      message: '  ' + getTranslated(context, 'loading'),
      messageTextStyle: TextStyle(color: DARK),
      progressWidget: circularProgressIndicator(),
    );
    return progressDialog;
  }
}
