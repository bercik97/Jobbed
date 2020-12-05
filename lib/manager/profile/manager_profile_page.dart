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
import 'package:give_job/shared/widget/buttons.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';

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
                Container(
                  width: 150,
                  height: 150,
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(image: AssetImage('images/manager-icon.png')),
                  ),
                ),
                Column(
                  children: <Widget>[
                    text25WhiteBold(_user.info),
                    SizedBox(height: 2.5),
                    text20White(LanguageUtil.convertShortNameToFullName(this.context, _user.nationality) + ' ' + LanguageUtil.findFlagByNationality(_user.nationality)),
                    SizedBox(height: 2.5),
                    text18White(getTranslated(context, 'manager') + ' #' + _user.id),
                    SizedBox(height: 30),
                    Buttons.standardButton(
                      minWidth: 200.0,
                      color: GREEN,
                      title: getTranslated(context, 'seeMyGroups'),
                      fun: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupsDashboardPage(_user),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Buttons.standardButton(
                      minWidth: 200.0,
                      color: GREEN,
                      title: getTranslated(context, 'settings'),
                      fun: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsPage(_user),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Buttons.standardButton(
                      minWidth: 200.0,
                      color: GREEN,
                      title: getTranslated(context, 'logout'),
                      fun: () => Logout.logout(context),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
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
