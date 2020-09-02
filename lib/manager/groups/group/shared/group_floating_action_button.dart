import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:give_job/manager/groups/group/employee/manager_employees_page.dart';
import 'package:give_job/manager/groups/group/employee/model/group_employee_model.dart';
import 'package:give_job/manager/groups/group/quick_update/quick_update_dialog.dart';
import 'package:give_job/manager/groups/group/timesheets/manager_ts_page.dart';
import 'package:give_job/manager/groups/manager_groups_page.dart';
import 'package:give_job/shared/libraries/colors.dart';

import '../manager_group_details_page.dart';

Widget groupFloatingActionButton(
    BuildContext context, GroupEmployeeModel model) {
  return SpeedDial(
    backgroundColor: GREEN,
    animatedIcon: AnimatedIcons.view_list,
    animatedIconTheme: IconThemeData(color: DARK),
    children: [
      SpeedDialChild(
        child: Image(
          image: AssetImage('images/group-img.png'),
          fit: BoxFit.fitHeight,
        ),
        label: 'Group',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ManagerGroupDetailsPage(model)),
          );
        },
      ),
      SpeedDialChild(
        child: Icon(Icons.group),
        label: 'Groups',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ManagerGroupsPage(model.user)),
          );
        },
      ),
      SpeedDialChild(
        child: Icon(Icons.person_outline),
        label: 'Employees',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ManagerEmployeesPage(model)),
          );
        },
      ),
      SpeedDialChild(
        child: Icon(Icons.today),
        label: 'Quick update',
        onTap: () => QuickUpdateDialog.showQuickUpdateDialog(context, model),
      ),
      SpeedDialChild(
        child: Icon(Icons.event_note),
        label: 'Timesheets',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ManagerTsPage(model)),
          );
        },
      ),
    ],
  );
}
