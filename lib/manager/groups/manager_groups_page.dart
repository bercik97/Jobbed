import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/dto/manager_group_dto.dart';
import 'package:give_job/manager/groups/group/employee/model/group_employee_model.dart';
import 'package:give_job/manager/manager_side_bar.dart';
import 'package:give_job/manager/service/manager_service.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/logout_service.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/widget/texts.dart';

import '../../shared/widget/loader.dart';
import '../manager_app_bar.dart';
import 'group/manager_group_details_page.dart';

class ManagerGroupsPage extends StatefulWidget {
  final User _user;

  ManagerGroupsPage(this._user);

  @override
  _ManagerGroupsPageState createState() => _ManagerGroupsPageState();
}

class _ManagerGroupsPageState extends State<ManagerGroupsPage> {
  User _user;
  ManagerService _managerService;

  List<ManagerGroupDto> _groups = new List();

  @override
  Widget build(BuildContext context) {
    this._user = widget._user;
    this._managerService = new ManagerService(context, _user.authHeader);
    return WillPopScope(
      child: FutureBuilder<List<ManagerGroupDto>>(
        future: _managerService.findGroupsManager(_user.id),
        builder: (BuildContext context,
            AsyncSnapshot<List<ManagerGroupDto>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.data == null) {
            return loader(
                managerAppBar(
                    context, _user, getTranslated(context, 'loading')),
                managerSideBar(context, _user));
          } else {
            this._groups = snapshot.data;
            return MaterialApp(
              title: APP_NAME,
              theme: ThemeData(
                  primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                backgroundColor: DARK,
                appBar: managerAppBar(
                    context, _user, getTranslated(context, 'groups')),
                drawer: managerSideBar(context, _user),
                body: Column(
                  children: <Widget>[
                    _groups.isNotEmpty ? _handleGroups() : _handleNoGroups()
                  ],
                ),
              ),
            );
          }
        },
      ),
      onWillPop: _onWillPop,
    );
  }

  Widget _handleGroups() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            for (int i = 0; i < _groups.length; i++)
              Card(
                color: BRIGHTER_DARK,
                child: InkWell(
                  onTap: () {
                    ManagerGroupDto group = _groups[i];
                    Navigator.of(context).push(
                      CupertinoPageRoute<Null>(
                        builder: (BuildContext context) {
                          return ManagerGroupDetailsPage(new GroupEmployeeModel(
                              _user,
                              group.id,
                              group.name,
                              group.description,
                              group.numberOfEmployees.toString(),
                              group.countryOfWork));
                        },
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      ListTile(
                        leading: Tab(
                          icon: Padding(
                            padding: EdgeInsets.only(top: 13),
                            child: Container(
                              child: Image(
                                width: 75,
                                image: AssetImage(
                                  'images/big-group-icon.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        title: text18WhiteBold(
                          utf8.decode(
                            _groups[i].name != null
                                ? _groups[i].name.runes.toList()
                                : getTranslated(context, 'empty'),
                          ),
                        ),
                        subtitle: Column(
                          children: <Widget>[
                            Align(
                                child: textWhite(utf8.decode(
                                    _groups[i].description != null
                                        ? _groups[i].description.runes.toList()
                                        : getTranslated(context, 'empty'))),
                                alignment: Alignment.topLeft),
                            SizedBox(height: 5),
                            Align(
                                child: textWhite(getTranslated(
                                        context, 'numberOfEmployees') +
                                    ': ' +
                                    _groups[i].numberOfEmployees.toString()),
                                alignment: Alignment.topLeft),
                            Align(
                                child: textWhite(getTranslated(
                                        context, 'groupCountryOfWork') +
                                    ': ' +
                                    LanguageUtil.findFlagByNationality(
                                        _groups[i].countryOfWork.toString())),
                                alignment: Alignment.topLeft),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _handleNoGroups() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Align(
              alignment: Alignment.center,
              child: text20GreenBold(
                  getTranslated(context, 'welcome') + ' ' + _user.info)),
        ),
        Padding(
          padding: EdgeInsets.only(right: 30, left: 30, top: 10),
          child: Align(
              alignment: Alignment.center,
              child: textCenter19White(
                  getTranslated(context, 'loggedSuccessButNoGroups'))),
        ),
      ],
    );
  }

  Future<bool> _onWillPop() async {
    return Logout.logout(context) ?? false;
  }
}
