import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/employees_settings/employees_settings_page.dart';
import 'package:give_job/manager/groups/group/pricelist/pricelist_page.dart';
import 'package:give_job/manager/groups/group/quick_update/quick_update_dialog.dart';
import 'package:give_job/manager/groups/group/timesheets/ts_page.dart';
import 'package:give_job/manager/groups/group/warehouse/warehouse_page.dart';
import 'package:give_job/manager/groups/group/workplace/workplaces_page.dart';
import 'package:give_job/manager/shared/group_model.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';

import '../../shared/manager_app_bar.dart';
import '../groups_dashboard_page.dart';
import 'edit/group_edit_page.dart';
import 'employee/employees_page.dart';
import 'itemplaces/itemplaces_page.dart';

class GroupPage extends StatefulWidget {
  final GroupModel _model;

  GroupPage(this._model);

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  GroupModel _model;
  User _user;

  @override
  Widget build(BuildContext context) {
    this._model = widget._model;
    this._user = _model.user;
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: DARK,
          appBar: managerAppBar(
            context,
            _user,
            getTranslated(context, 'group') + ' - ' + utf8.decode(_model.groupName != null ? _model.groupName.runes.toList() : '-'),
            () => NavigatorUtil.navigate(context, GroupsDashboardPage(_user)),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
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
                                  'images/group-icon.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      title: text18WhiteBold(
                        utf8.decode(
                          _model.groupName != null ? _model.groupName.runes.toList() : getTranslated(context, 'empty'),
                        ),
                      ),
                      subtitle: Column(
                        children: <Widget>[
                          Align(
                            child: textWhite(utf8.decode(_model.groupDescription != null ? _model.groupDescription.runes.toList() : getTranslated(context, 'empty'))),
                            alignment: Alignment.topLeft,
                          ),
                          SizedBox(height: 5),
                          Align(
                            child: textWhite(getTranslated(context, 'numberOfEmployees') + ': ' + _model.numberOfEmployees.toString()),
                            alignment: Alignment.topLeft,
                          ),
                        ],
                      ),
                      trailing: Ink(
                        decoration: ShapeDecoration(color: GREEN, shape: CircleBorder()),
                        child: IconButton(
                          icon: iconDark(Icons.border_color),
                          onPressed: () => NavigatorUtil.navigate(this.context, GroupEditPage(_model)),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Material(
                            color: BRIGHTER_DARK,
                            child: InkWell(
                              onTap: () => NavigatorUtil.navigate(context, EmployeesSettingsPage(_model)),
                              child: _buildScrollableContainer('images/employees-settings-icon.png', 'settings', 'employeesSettingsDescription'),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Material(
                            color: BRIGHTER_DARK,
                            child: InkWell(
                              onTap: () => NavigatorUtil.navigate(context, EmployeesPage(_model)),
                              child: _buildScrollableContainer('images/employees-icon.png', 'employees', 'manageSelectedEmployee'),
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
                              onTap: () => NavigatorUtil.navigate(context, TsPage(_model)),
                              child: _buildScrollableContainer('images/timesheets-icon.png', 'timesheets', 'fillHoursPieceworks'),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Material(
                            color: BRIGHTER_DARK,
                            child: InkWell(
                              onTap: () => QuickUpdateDialog.showQuickUpdateDialog(context, _model),
                              child: _buildScrollableContainer('images/quick_update-icon.png', 'quickUpdate', 'quickUpdateDescription'),
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
                              onTap: () => NavigatorUtil.navigate(context, WorkplacesPage(_model)),
                              child: _buildScrollableContainer('images/workplace-icon.png', 'workplaces', 'manageCompanyWorkplaces'),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Material(
                            color: BRIGHTER_DARK,
                            child: InkWell(
                              onTap: () => NavigatorUtil.navigate(context, PricelistPage(_model)),
                              child: _buildScrollableContainer('images/pricelist-icon.png', 'pricelist', 'manageCompanyPricelist'),
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
                              onTap: () => NavigatorUtil.navigate(context, WarehousePage(_model)),
                              child: _buildScrollableContainer('images/warehouse-icon.png', 'warehouses', 'manageCompanyWarehouses'),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Material(
                            color: BRIGHTER_DARK,
                            child: InkWell(
                              onTap: () => NavigatorUtil.navigate(context, ItemplacesPage(_model)),
                              child: _buildScrollableContainer('images/items-icon.png', 'itemPlaces', 'manageCompanyItemPlaces'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, GroupsDashboardPage(_user)),
    );
  }

  Widget _buildScrollableContainer(String imagePath, String title, String subtitle) {
    return Container(
      height: 170,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            Image(height: 100, image: AssetImage(imagePath)),
            textCenter16WhiteBold(getTranslated(context, title)),
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: textCenter13White(
                getTranslated(context, subtitle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
