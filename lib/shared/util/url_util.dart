import 'package:flutter/cupertino.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/util/toast_util.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlUtil {

  static void launchURL(BuildContext context, String url) async {
    await canLaunch(url)
        ? await launch(url)
        : ToastUtil.showErrorToast(getTranslated(context, 'couldNotLaunch'));
  }
}
