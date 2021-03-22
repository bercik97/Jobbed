import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jobbed/api/employee/dto/employee_profile_dto.dart';
import 'package:jobbed/employee/profile/tabs/piecework/piecework_page.dart';
import 'package:jobbed/employee/profile/tabs/schedule/employee_schedule_page.dart';
import 'package:jobbed/employee/profile/tabs/timesheet/employee_timesheet_page.dart';
import 'package:jobbed/employee/profile/tabs/worktime/work_time_page.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/widget/texts.dart';

Container employeePanel(BuildContext context, User user, EmployeeProfileDto employee) {
  return Container(
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(width: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: Material(
                    color: BRIGHTER_BLUE,
                    child: InkWell(
                      onTap: () async {
                        num todayWorkdayId = employee.todayWorkdayId;
                        if (todayWorkdayId == 0) {
                          DialogUtil.showErrorDialog(context, getTranslated(context, 'cannotStartWorkWithoutTS'));
                          return;
                        }
                        if (!employee.workTimeByLocation) {
                          DialogUtil.showErrorDialog(context, getTranslated(context, 'noPermissionForWorkTimeByLocation'));
                          return;
                        }
                        NavigatorUtil.navigate(context, WorkTimePage(user, employee.id, todayWorkdayId));
                      },
                      child: _buildScrollableContainer(context, 'images/work-time.png', 'workTime', 'startFinishWork'),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Material(
                    color: BRIGHTER_BLUE,
                    child: InkWell(
                      onTap: () async {
                        int todayWorkdayId = employee.todayWorkdayId;
                        if (todayWorkdayId == 0) {
                          DialogUtil.showErrorDialog(context, getTranslated(context, 'cannotStartWorkWithoutTS'));
                          return;
                        }
                        if (!employee.piecework) {
                          DialogUtil.showErrorDialog(context, getTranslated(context, 'noPermissionForPiecework'));
                          return;
                        }
                        NavigatorUtil.navigate(context, PieceworkPage(user, employee.todayDate, employee.todayWorkdayId));
                      },
                      child: _buildScrollableContainer(context, 'images/piecework.png', 'piecework', 'addNoteAboutPiecework'),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Material(
                    color: BRIGHTER_BLUE,
                    child: InkWell(
                      onTap: () async => NavigatorUtil.navigate(context, EmployeeSchedulePage(user, employee.id)),
                      child: _buildScrollableContainer(context, 'images/calendar.png', 'schedule', 'checkYourCalendar'),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Material(
                    color: BRIGHTER_BLUE,
                    child: InkWell(
                      onTap: () async => NavigatorUtil.navigate(context, EmployeeTimesheetPage(user, employee.timeSheets)),
                      child: _buildScrollableContainer(context, 'images/timesheet.png', 'timesheets', 'timesheetsDescription'),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ),
  );
}

Widget _buildScrollableContainer(BuildContext context, String imagePath, String title, String subtitle) {
  return Container(
    height: 170,
    child: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: <Widget>[
          Image(height: 100, image: AssetImage(imagePath)),
          textCenter17BlueBold(getTranslated(context, title)),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: textCenter13Black(getTranslated(context, subtitle)),
          ),
          SizedBox(height: 10),
        ],
      ),
    ),
  );
}
