import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/dto/manager_dto.dart';
import 'package:give_job/manager/groups/groups_dashboard_page.dart';
import 'package:give_job/manager/manager_side_bar.dart';
import 'package:give_job/manager/service/manager_service.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/logout_service.dart';
import 'package:give_job/shared/settings/settings_page.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/loader.dart';
import 'package:give_job/shared/widget/texts.dart';

import '../manager_app_bar.dart';

class ManagerProfilePage extends StatefulWidget {
  final User _user;

  ManagerProfilePage(this._user);

  @override
  _ManagerProfilePageState createState() => _ManagerProfilePageState();
}

class _ManagerProfilePageState extends State<ManagerProfilePage> {
  ManagerDto _manager;

  User _user;
  ManagerService _managerService;

  @override
  Widget build(BuildContext context) {
    this._user = widget._user;
    this._managerService = new ManagerService(context, _user.authHeader);
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
                    image: DecorationImage(
                        image: AssetImage('images/big-manager-icon.png')),
                  ),
                ),
                Column(
                  children: <Widget>[
                    text25WhiteBold(utf8.decode(
                        _user.info != null ? _user.info.runes.toList() : '-')),
                    SizedBox(height: 2.5),
                    text20White(LanguageUtil.convertShortNameToFullName(
                            this.context, _user.nationality) +
                        ' ' +
                        LanguageUtil.findFlagByNationality(_user.nationality)),
                    SizedBox(height: 2.5),
                    text18White(
                        getTranslated(context, 'manager') + ' #' + _user.id),
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
                      getTranslated(context, 'aboutMe'),
                      Icons.info,
                      () => {
                        showGeneralDialog(
                          context: context,
                          barrierColor: DARK.withOpacity(0.95),
                          barrierDismissible: false,
                          barrierLabel: getTranslated(context, 'hours'),
                          transitionDuration: Duration(milliseconds: 400),
                          pageBuilder: (_, __, ___) {
                            return FutureBuilder<ManagerDto>(
                              future: _managerService.findById(widget._user.id),
                              builder: (BuildContext context,
                                  AsyncSnapshot<ManagerDto> snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.waiting ||
                                    snapshot.data == null) {
                                  return loader(
                                    managerAppBar(context, null,
                                        getTranslated(context, 'loading')),
                                    managerSideBar(context, widget._user),
                                  );
                                } else {
                                  _manager = snapshot.data;
                                  return Padding(
                                    padding: EdgeInsets.only(top: 60),
                                    child: Scaffold(
                                      backgroundColor: Colors.black12,
                                      body: SingleChildScrollView(
                                        child: Center(
                                          child: Column(
                                            children: <Widget>[
                                              _buildBasicInformationsSection(),
                                              _buildContactSection(),
                                              _buildGroupSection(),
                                            ],
                                          ),
                                        ),
                                      ),
                                      bottomNavigationBar: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 20),
                                            child: MaterialButton(
                                              elevation: 0,
                                              height: 50,
                                              minWidth: 100,
                                              shape: new RoundedRectangleBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          30.0)),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  iconWhite(Icons.close)
                                                ],
                                              ),
                                              color: Colors.red,
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
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
                    _buildButton(getTranslated(context, 'logout'),
                        Icons.exit_to_app, () => Logout.logout(context)),
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
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0)),
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

  Widget _buildBasicInformationsSection() {
    return Column(
      children: <Widget>[
        _buildSectionTitle(getTranslated(context, 'basicInformations')),
        _buildListTile(
            getTranslated(context, 'name'),
            utf8.decode(_manager.name != null
                ? _manager.name.runes.toList()
                : getTranslated(context, 'empty'))),
        _buildListTile(
            getTranslated(context, 'surname'),
            utf8.decode(_manager.surname != null
                ? _manager.surname.runes.toList()
                : getTranslated(context, 'empty'))),
        _buildListTile(
            getTranslated(context, 'username'),
            utf8.decode(_manager.username != null
                ? _manager.username.runes.toList()
                : getTranslated(context, 'empty'))),
        _buildListTile(
            getTranslated(context, 'nationality'),
            _manager.nationality != null && _manager.nationality != 'Brak'
                ? LanguageUtil.findFlagByNationality(_manager.nationality) +
                    ' ' +
                    utf8.decode(_manager.nationality.runes.toList())
                : getTranslated(context, 'empty')),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      children: <Widget>[
        _buildSectionTitle(getTranslated(context, 'contact')),
        _buildListTile(
            getTranslated(context, 'email'),
            _manager.email != null
                ? utf8.decode(_manager.email.runes.toList())
                : getTranslated(context, 'empty')),
        _buildListTile(
            getTranslated(context, 'phone'),
            _manager.phoneNumber != null
                ? _manager.phoneNumber
                : getTranslated(context, 'empty')),
        _buildListTile(
            getTranslated(context, 'viber'),
            _manager.viberNumber != null
                ? _manager.viberNumber
                : getTranslated(context, 'empty')),
        _buildListTile(
            getTranslated(context, 'whatsApp'),
            _manager.whatsAppNumber != null
                ? _manager.whatsAppNumber
                : getTranslated(context, 'empty')),
      ],
    );
  }

  Widget _buildGroupSection() {
    return Column(
      children: <Widget>[
        _buildSectionTitle(getTranslated(context, 'group')),
        _buildListTile(
            getTranslated(context, 'numberOfGroups'),
            _manager.numberOfGroups != null
                ? _manager.numberOfGroups.toString()
                : getTranslated(context, 'empty')),
        _buildListTile(
            getTranslated(context, 'numberOfEmployeesInGroups'),
            _manager.numberOfEmployeesInGroups != null
                ? _manager.numberOfEmployeesInGroups.toString()
                : getTranslated(context, 'empty')),
      ],
    );
  }

  Widget _buildSectionTitle(String text) {
    return Column(
      children: <Widget>[
        Container(width: 200, child: Divider(color: WHITE)),
        text20GreenBold(text),
        Container(width: 200, child: Divider(color: WHITE)),
      ],
    );
  }

  Widget _buildListTile(String title, String subtile) {
    return ListTile(
      title: textCenter18WhiteBold(title),
      subtitle: textCenter16White(subtile),
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
