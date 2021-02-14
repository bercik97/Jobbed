import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/api/employee/dto/employee_profile_dto.dart';
import 'package:give_job/employee/profile/tabs/calendar/employee_calendar_page.dart';
import 'package:give_job/employee/profile/tabs/piecework/piecework_page.dart';
import 'package:give_job/employee/profile/tabs/worktime/work_time_page.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/texts.dart';

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
                    color: BRIGHTER_DARK,
                    child: InkWell(
                      onTap: () async {
                        int todayWorkdayId = employee.todayWorkdayId;
                        if (todayWorkdayId == 0) {
                          ToastService.showErrorToast(getTranslated(context, 'cannotStartWorkWithoutTS'));
                          return;
                        }
                        if (!employee.workTimeByLocation) {
                          ToastService.showErrorToast(getTranslated(context, 'noPermissionForWorkTimeByLocation'));
                          return;
                        }
                        NavigatorUtil.navigate(context, WorkTimePage(user, employee.todayWorkdayId));
                      },
                      child: _buildScrollableContainer(context, 'images/employee-work-icon.png', 'workTimeGPS', 'startFinishWork'),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Material(
                    color: BRIGHTER_DARK,
                    child: InkWell(
                      onTap: () async {
                        int todayWorkdayId = employee.todayWorkdayId;
                        if (todayWorkdayId == 0) {
                          ToastService.showErrorToast(getTranslated(context, 'cannotStartWorkWithoutTS'));
                          return;
                        }
                        if (!employee.piecework) {
                          ToastService.showErrorToast(getTranslated(context, 'noPermissionForPiecework'));
                          return;
                        }
                        NavigatorUtil.navigate(context, PieceworkPage(user, employee.todayDate, employee.todayWorkdayId));
                      },
                      child: _buildScrollableContainer(context, 'images/green-piecework-icon.png', 'piecework', 'addNoteAboutPiecework'),
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
                    color: BRIGHTER_DARK,
                    child: InkWell(
                      onTap: () async => NavigatorUtil.navigate(context, EmployeeCalendarPage(user, employee.id)),
                      child: _buildScrollableContainer(context, 'images/calendar-icon.png', 'calendar', 'checkYourCalendar'),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(child: Material(color: BRIGHTER_DARK)),
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
          textCenter16WhiteBold(getTranslated(context, title)),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: textCenter13White(getTranslated(context, subtitle)),
          ),
          SizedBox(height: 10),
        ],
      ),
    ),
  );
}
