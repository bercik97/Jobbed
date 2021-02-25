import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:give_job/employee/profile/timesheet/employee_ts_completed_page.dart';
import 'package:give_job/employee/profile/timesheet/employee_ts_in_progress_page.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/util/month_util.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/texts.dart';

Widget employeeTimesheetsTab(BuildContext context, bool canFillHours, User user, List sheets) {
  if (sheets.isEmpty) {
    return _handleEmptyData(context);
  }
  return Container(
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            for (var timesheet in sheets)
              Card(
                color: BRIGHTER_DARK,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      onTap: () async {
                        if (timesheet.status == STATUS_IN_PROGRESS) {
                          NavigatorUtil.navigate(context, EmployeeTsInProgressPage(canFillHours, user, timesheet));
                        } else {
                          NavigatorUtil.navigate(context, EmployeeTsCompletedPage(user, timesheet));
                        }
                      },
                      child: ListTile(
                        leading: Padding(
                          padding: EdgeInsets.only(bottom: 15),
                          child: Image(
                            image: timesheet.status == STATUS_IN_PROGRESS ? AssetImage('images/unchecked.png') : AssetImage('images/checked.png'),
                          ),
                        ),
                        title: textWhiteBold(timesheet.year.toString() + ' ' + MonthUtil.translateMonth(context, timesheet.month)),
                        subtitle: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                textWhite(getTranslated(context, 'hours') + ': '),
                                textGreenBold(timesheet.totalMoneyForHoursForEmployee.toString() + ' PLN' + ' (' + timesheet.totalHours + ' h)'),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                textWhite(getTranslated(context, 'accord') + ': '),
                                textGreenBold(timesheet.totalMoneyForPieceworkForEmployee.toString() + ' PLN'),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                textWhite(getTranslated(context, 'time') + ': '),
                                textGreenBold(timesheet.totalMoneyForTimeForEmployee.toString() + ' PLN'),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                textWhite(getTranslated(context, 'sum') + ': '),
                                textGreenBold(timesheet.totalMoneyEarned.toString() + ' PLN'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

Widget _handleEmptyData(BuildContext context) {
  return Container(
    child: Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Align(
            alignment: Alignment.center,
            child: text20GreenBold(getTranslated(context, 'noTimesheets')),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Align(
            alignment: Alignment.center,
            child: textCenter19White(getTranslated(context, 'noTimesheetsYet')),
          ),
        ),
      ],
    ),
  );
}
