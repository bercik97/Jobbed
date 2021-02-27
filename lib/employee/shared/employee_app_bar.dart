import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/settings/settings_page.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';

AppBar employeeAppBar(BuildContext context, User user, String title, Function() fun) {
  return AppBar(
    iconTheme: IconThemeData(color: WHITE),
    backgroundColor: WHITE,
    elevation: 0.0,
    bottomOpacity: 0.0,
    title: text13Black(title),
    centerTitle: false,
    automaticallyImplyLeading: true,
    leading: IconButton(icon: iconBlack(Icons.arrow_back), onPressed: () => fun()),
    actions: <Widget>[
      Padding(
        padding: EdgeInsets.only(right: 15.0),
        child: IconButton(
          icon: iconBlack(Icons.settings),
          onPressed: () => NavigatorUtil.navigate(context, SettingsPage(user)),
        ),
      ),
    ],
  );
}
