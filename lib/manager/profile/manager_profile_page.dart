import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/groups_dashboard_page.dart';
import 'package:give_job/manager/shared/manager_side_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/logout_service.dart';
import 'package:give_job/shared/settings/settings_page.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';

import 'edit/manager_edit_page.dart';

class ManagerProfilePage extends StatefulWidget {
  final User _user;

  ManagerProfilePage(this._user);

  @override
  _ManagerProfilePageState createState() => _ManagerProfilePageState();
}

class _ManagerProfilePageState extends State<ManagerProfilePage> {
  User _user;

  @override
  Widget build(BuildContext context) {
    this._user = widget._user;
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: DARK,
        appBar: _buildAppBar(context, _user),
        drawer: managerSideBar(context, _user),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      margin: EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(image: AssetImage('images/manager-icon.png')),
                      ),
                    ),
                    Ink(
                      decoration: ShapeDecoration(color: GREEN, shape: CircleBorder()),
                      child: IconButton(
                        icon: iconDark(Icons.border_color),
                        onPressed: () => Navigator.push(
                          this.context,
                          MaterialPageRoute(
                            builder: (context) => ManagerEditPage(_user),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    text25WhiteBold(utf8.decode(_user.info != null ? _user.info.runes.toList() : '-')),
                    SizedBox(height: 2.5),
                    text20White(LanguageUtil.convertShortNameToFullName(this.context, _user.nationality) + ' ' + LanguageUtil.findFlagByNationality(_user.nationality)),
                    SizedBox(height: 2.5),
                    text18White(getTranslated(context, 'manager') + ' #' + _user.id),
                    SizedBox(height: 10),
                    _buildButton(
                      getTranslated(context, 'seeMyGroups'),
                      Icons.group,
                      () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupsDashboardPage(_user),
                          ),
                        ),
                      },
                    ),
                    _buildButton(
                      getTranslated(context, 'settings'),
                      Icons.settings,
                      () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsPage(_user),
                          ),
                        ),
                      },
                    ),
                    _buildButton(getTranslated(context, 'logout'), Icons.exit_to_app, () => Logout.logout(context)),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, IconData icon, Function() fun) {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: MaterialButton(
        elevation: 0,
        height: 50,
        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
        onPressed: () => fun(),
        color: GREEN,
        child: Container(
          width: 250,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              text20White(text),
              iconWhite(icon),
            ],
          ),
        ),
        textColor: Colors.white,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, User user) {
    return AppBar(
      iconTheme: IconThemeData(color: WHITE),
      backgroundColor: BRIGHTER_DARK,
      elevation: 0.0,
      bottomOpacity: 0.0,
      title: text15White(getTranslated(context, 'profile')),
      actions: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: 15.0),
          child: IconButton(
            icon: iconWhite(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage(user)),
              );
            },
          ),
        ),
      ],
    );
  }
}
