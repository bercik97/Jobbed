import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/employee/manager_employees_page.dart';
import 'package:give_job/manager/groups/group/employee/model/group_employee_model.dart';
import 'package:give_job/manager/groups/group/quick_update/quick_update_dialog.dart';
import 'package:give_job/manager/groups/group/timesheets/manager_ts_page.dart';
import 'package:give_job/manager/groups/group/vocations/manager_vocations_ts_page.dart';
import 'package:give_job/manager/groups/group/workplaces/manage_group_workplaces_page.dart';
import 'package:give_job/manager/groups/manager_groups_page.dart';
import 'package:give_job/shared/libraries/colors.dart';

import '../manager_group_details_page.dart';

Widget groupFloatingActionButton(
    BuildContext context, GroupEmployeeModel model) {
  return SpeedDial(
    backgroundColor: GREEN,
    animatedIcon: AnimatedIcons.view_list,
    animatedIconTheme: IconThemeData(color: BRIGHTER_DARK),
    children: [
      SpeedDialChild(
        backgroundColor: BRIGHTER_DARK,
        child: Image(image: AssetImage('images/small-group-icon.png')),
        label: getTranslated(context, 'group'),
        labelBackgroundColor: BRIGHTER_DARK,
        labelStyle: TextStyle(color: WHITE),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ManagerGroupDetailsPage(model)),
          );
        },
      ),
      SpeedDialChild(
        backgroundColor: BRIGHTER_DARK,
        child: Image(image: AssetImage('images/small-groups-icon.png')),
        label: getTranslated(context, 'backToGroups'),
        labelBackgroundColor: BRIGHTER_DARK,
        labelStyle: TextStyle(color: WHITE),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ManagerGroupsPage(model.user)),
          );
        },
      ),
      SpeedDialChild(
        backgroundColor: BRIGHTER_DARK,
        child: Image(image: AssetImage('images/small-employees-icon.png')),
        label: getTranslated(context, 'employees'),
        labelBackgroundColor: BRIGHTER_DARK,
        labelStyle: TextStyle(color: WHITE),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ManagerEmployeesPage(model)),
          );
        },
      ),
      SpeedDialChild(
        backgroundColor: BRIGHTER_DARK,
        child: Image(image: AssetImage('images/small-quick_update-icon.png')),
        label: getTranslated(context, 'quickUpdate'),
        labelBackgroundColor: BRIGHTER_DARK,
        labelStyle: TextStyle(color: WHITE),
        onTap: () => QuickUpdateDialog.showQuickUpdateDialog(context, model),
      ),
      SpeedDialChild(
        backgroundColor: BRIGHTER_DARK,
        child: Image(image: AssetImage('images/small-timesheets-icon.png')),
        label: getTranslated(context, 'timesheets'),
        labelBackgroundColor: BRIGHTER_DARK,
        labelStyle: TextStyle(color: WHITE),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ManagerTsPage(model)),
          );
        },
      ),
      SpeedDialChild(
        backgroundColor: BRIGHTER_DARK,
        child: Image(image: AssetImage('images/small-vocation-icon.png')),
        label: getTranslated(context, 'vocations'),
        labelBackgroundColor: BRIGHTER_DARK,
        labelStyle: TextStyle(color: WHITE),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ManagerVocationsTsPage(model)),
          );
        },
      ),
      SpeedDialChild(
        backgroundColor: BRIGHTER_DARK,
        child: Image(image: AssetImage('images/small-workplace-icon.png')),
        label: getTranslated(context, 'workplaces'),
        labelBackgroundColor: BRIGHTER_DARK,
        labelStyle: TextStyle(color: WHITE),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ManageGroupWorkplacesPage(model)),
          );
        },
      ),
    ],
  );
}
