import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/settings/settings_page.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';

AppBar managerAppBar(BuildContext context, User user, String title) {
  return AppBar(
    iconTheme: IconThemeData(color: WHITE),
    backgroundColor: BRIGHTER_DARK,
    elevation: 0.0,
    bottomOpacity: 0.0,
    title: text13White(title),
    centerTitle: false,
    automaticallyImplyLeading: true,
    leading: IconButton(icon: iconWhite(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
    actions: <Widget>[
      Padding(
        padding: EdgeInsets.only(right: 15.0),
        child: IconButton(
          icon: iconWhite(Icons.settings),
          onPressed: () => NavigatorUtil.navigate(context, SettingsPage(user)),
        ),
      ),
    ],
  );
}
