import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/groups/group/employees_settings/employees_settings_page.dart';
import 'package:jobbed/manager/groups/group/piecework/piecework_page.dart';
import 'package:jobbed/manager/groups/group/price_list/price_lists_page.dart';
import 'package:jobbed/manager/groups/group/schedule/schedule_page.dart';
import 'package:jobbed/manager/groups/group/timesheets/ts_page.dart';
import 'package:jobbed/manager/groups/group/work_time/work_time_page.dart';
import 'package:jobbed/manager/groups/group/workplace/workplaces_page.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/widget/expandable_text.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';

import '../../shared/manager_app_bar.dart';
import '../groups_dashboard_page.dart';
import 'edit/group_edit_page.dart';

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
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: managerAppBar(context, _user, getTranslated(context, 'group'), () => NavigatorUtil.navigateReplacement(context, GroupsDashboardPage(_user))),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: Tab(
                      icon: Container(
                        child: Container(
                          child: Image(
                            width: 75,
                            image: AssetImage('images/group.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    title: text17BlueBold(_model.groupName),
                    subtitle: buildExpandableText(context, _model.groupDescription, 2, 16),
                    trailing: Ink(
                      decoration: ShapeDecoration(color: BLUE, shape: CircleBorder()),
                      child: IconButton(
                        icon: iconWhite(Icons.border_color),
                        onPressed: () => NavigatorUtil.navigate(this.context, GroupEditPage(_model)),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Material(
                          color: BRIGHTER_BLUE,
                          child: InkWell(
                            onTap: () => NavigatorUtil.navigate(context, EmployeesSettingsPage(_model)),
                            child: _buildScrollableContainer('images/employees-settings.png', 'permissions', 'permissionsDescription'),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Material(
                          color: BRIGHTER_BLUE,
                          child: InkWell(
                            onTap: () => NavigatorUtil.navigate(context, SchedulePage(_model)),
                            child: _buildScrollableContainer('images/calendar.png', 'schedule', 'checkSchedule'),
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
                          color: BRIGHTER_BLUE,
                          child: InkWell(
                            onTap: () => NavigatorUtil.navigate(context, WorkTimePage(_model)),
                            child: _buildScrollableContainer('images/work-time.png', 'workTimes', 'manageEmployeesWorkTime'),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Material(
                          color: BRIGHTER_BLUE,
                          child: InkWell(
                            onTap: () => NavigatorUtil.navigate(context, WorkplacesPage(_model)),
                            child: _buildScrollableContainer('images/workplace.png', 'workplaces', 'manageCompanyWorkplaces'),
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
                          color: BRIGHTER_BLUE,
                          child: InkWell(
                            onTap: () => NavigatorUtil.navigate(context, PieceworkPage(_model)),
                            child: _buildScrollableContainer('images/piecework.png', 'pieceworks', 'pieceworksDescription'),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Material(
                          color: BRIGHTER_BLUE,
                          child: InkWell(
                            onTap: () => NavigatorUtil.navigate(context, PriceListsPage(_model)),
                            child: _buildScrollableContainer('images/price-list.png', 'priceList', 'manageCompanyPriceList'),
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
                          color: BRIGHTER_BLUE,
                          child: InkWell(
                            onTap: () => NavigatorUtil.navigate(context, TsPage(_model)),
                            child: _buildScrollableContainer('images/timesheet.png', 'timesheets', 'timesheetsDescription'),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(child: Material(color: BRIGHTER_BLUE)),
                    ],
                  ),
                ],
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
            Image(height: 90, image: AssetImage(imagePath)),
            textCenter16BlueBold(getTranslated(context, title)),
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: textCenterBlack(getTranslated(context, subtitle)),
            ),
          ],
        ),
      ),
    );
  }
}
