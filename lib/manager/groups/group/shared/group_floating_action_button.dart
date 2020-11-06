import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/employee/employees_page.dart';
import 'package:give_job/manager/groups/group/icons_legend/icons_legend_dialog.dart';
import 'package:give_job/manager/groups/group/quick_update/quick_update_dialog.dart';
import 'package:give_job/manager/groups/group/shared/group_model.dart';
import 'package:give_job/manager/groups/group/timesheets/ts_page.dart';
import 'package:give_job/manager/groups/group/vocations/vocations_ts_page.dart';
import 'package:give_job/manager/groups/groups_dashboard_page.dart';
import 'package:give_job/shared/libraries/colors.dart';

import '../group_page.dart';

Widget groupFloatingActionButton(BuildContext context, GroupModel model) {
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
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GroupPage(model)),
        ),
      ),
      SpeedDialChild(
        backgroundColor: BRIGHTER_DARK,
        child: Image(image: AssetImage('images/small-groups-icon.png')),
        label: getTranslated(context, 'backToGroups'),
        labelBackgroundColor: BRIGHTER_DARK,
        labelStyle: TextStyle(color: WHITE),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GroupsDashboardPage(model.user)),
        ),
      ),
      SpeedDialChild(
        backgroundColor: BRIGHTER_DARK,
        child: Image(image: AssetImage('images/small-help-icon.png')),
        label: getTranslated(context, 'iconsLegend'),
        labelBackgroundColor: BRIGHTER_DARK,
        labelStyle: TextStyle(color: WHITE),
        onTap: () => IconsLegend.showIconsLegendDialog(context, model),
      ),
      SpeedDialChild(
        backgroundColor: BRIGHTER_DARK,
        child: Image(image: AssetImage('images/small-employees-icon.png')),
        label: getTranslated(context, 'employees'),
        labelBackgroundColor: BRIGHTER_DARK,
        labelStyle: TextStyle(color: WHITE),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EmployeesPage(model)),
        ),
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
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ManagerTsPage(model)),
        ),
      ),
      SpeedDialChild(
        backgroundColor: BRIGHTER_DARK,
        child: Image(image: AssetImage('images/small-vocation-icon.png')),
        label: getTranslated(context, 'vocations'),
        labelBackgroundColor: BRIGHTER_DARK,
        labelStyle: TextStyle(color: WHITE),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VocationsTsPage(model)),
        ),
      ),
    ],
  );
}
