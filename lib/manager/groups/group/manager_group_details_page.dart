import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/employee/model/group_employee_model.dart';
import 'package:give_job/manager/groups/group/quick_update/quick_update_dialog.dart';
import 'package:give_job/manager/groups/group/timesheets/manager_ts_page.dart';
import 'package:give_job/manager/groups/group/vocations/manager_vocations_page.dart';
import 'package:give_job/manager/manager_side_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/widget/texts.dart';

import '../../manager_app_bar.dart';
import '../manager_groups_page.dart';
import 'employee/manager_employees_page.dart';

class ManagerGroupDetailsPage extends StatefulWidget {
  final GroupEmployeeModel _model;

  ManagerGroupDetailsPage(this._model);

  @override
  _ManagerGroupDetailsPageState createState() =>
      _ManagerGroupDetailsPageState();
}

class _ManagerGroupDetailsPageState extends State<ManagerGroupDetailsPage> {
  GroupEmployeeModel _model;

  @override
  Widget build(BuildContext context) {
    this._model = widget._model;
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: DARK,
          appBar: managerAppBar(
              context,
              _model.user,
              getTranslated(context, 'group') +
                  ' - ' +
                  utf8.decode(_model.groupName != null
                      ? _model.groupName.runes.toList()
                      : '-')),
          drawer: managerSideBar(context, _model.user),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: Tab(
                      icon: Container(
                        child: Padding(
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
                    ),
                    title: text18WhiteBold(
                      utf8.decode(
                        _model.groupName != null
                            ? _model.groupName.runes.toList()
                            : getTranslated(context, 'empty'),
                      ),
                    ),
                    subtitle: Column(
                      children: <Widget>[
                        Align(
                            child: textWhite(utf8.decode(
                                _model.groupDescription != null
                                    ? _model.groupDescription.runes.toList()
                                    : getTranslated(context, 'empty'))),
                            alignment: Alignment.topLeft),
                        SizedBox(height: 5),
                        Align(
                            child: textWhite(
                                getTranslated(context, 'numberOfEmployees') +
                                    ': ' +
                                    _model.numberOfEmployees.toString()),
                            alignment: Alignment.topLeft),
                        Align(
                            child: textWhite(
                                getTranslated(context, 'groupCountryOfWork') +
                                    ': ' +
                                    LanguageUtil.findFlagByNationality(
                                        _model.countryOfWork.toString())),
                            alignment: Alignment.topLeft),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Material(
                          color: BRIGHTER_DARK,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute<Null>(
                                  builder: (BuildContext context) {
                                    return ManagerGroupsPage(_model.user);
                                  },
                                ),
                              );
                            },
                            child: _buildScrollableContainer(
                                'images/big-groups-icon.png',
                                'backToGroups',
                                'seeYourAllGroups'),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Material(
                          color: BRIGHTER_DARK,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute<Null>(
                                  builder: (BuildContext context) {
                                    return ManagerEmployeesPage(_model);
                                  },
                                ),
                              );
                            },
                            child: _buildScrollableContainer(
                                'images/big-employees-icon.png',
                                'employees',
                                'manageSelectedEmployee'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Material(
                          color: BRIGHTER_DARK,
                          child: InkWell(
                            onTap: () =>
                                QuickUpdateDialog.showQuickUpdateDialog(
                                    context, _model),
                            child: _buildScrollableContainer(
                                'images/big-quick_update-icon.png',
                                'quickUpdate',
                                'quickUpdateDescription'),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Material(
                          color: BRIGHTER_DARK,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute<Null>(
                                  builder: (BuildContext context) {
                                    return ManagerTsPage(_model);
                                  },
                                ),
                              );
                            },
                            child: _buildScrollableContainer(
                                'images/big-timesheets-icon.png',
                                'timesheets',
                                'fillHoursRatingPlans'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Material(
                          color: BRIGHTER_DARK,
                          child: InkWell(
                            onTap: () => {
                              Navigator.of(context).push(
                                CupertinoPageRoute<Null>(
                                  builder: (BuildContext context) {
                                    return ManagerVocationsPage(_model);
                                  },
                                ),
                              ),
                            },
                            child: _buildScrollableContainer(
                                'images/big-quick_update-icon.png',
                                'vocations',
                                'vocationsDescription'),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      onWillPop: _onWillPop,
    );
  }

  Widget _buildScrollableContainer(
      String imagePath, String title, String subtitle) {
    return Container(
      height: 160,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            Image(height: 100, image: AssetImage(imagePath)),
            text18WhiteBold(getTranslated(context, title)),
            Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: textCenter13White(getTranslated(context, subtitle))),
            SizedBox(height: 10)
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManagerGroupsPage(_model.user),
      ),
    );
    return false;
  }
}
