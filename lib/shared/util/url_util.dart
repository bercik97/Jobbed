import 'package:flutter/cupertino.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlUtil {

  static void launchURL(BuildContext context, String url) async {
    await canLaunch(url)
        ? await launch(url)
        : ToastUtil.showErrorToast(getTranslated(context, 'couldNotLaunch'));
  }
}
