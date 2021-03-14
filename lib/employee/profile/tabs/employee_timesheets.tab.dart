import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jobbed/employee/profile/timesheet/employee_ts_completed_page.dart';
import 'package:jobbed/employee/profile/timesheet/employee_ts_in_progress_page.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/month_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';

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
                color: BRIGHTER_BLUE,
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
                          padding: EdgeInsets.only(top: 25),
                          child: timesheet.status == STATUS_IN_PROGRESS ? icon30Orange(Icons.arrow_circle_up) : icon30Green(Icons.check_circle_outline),
                        ),
                        title: text17BlackBold(timesheet.year.toString() + ' ' + MonthUtil.translateMonth(context, timesheet.month)),
                        subtitle: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                text17BlackBold(getTranslated(context, 'accord') + ': '),
                                text16Black(timesheet.totalMoneyForPieceworkForEmployee.toString() + ' PLN'),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                text17BlackBold(getTranslated(context, 'time') + ': '),
                                text16Black(timesheet.totalMoneyForTimeForEmployee.toString() + ' PLN'),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                text17BlackBold(getTranslated(context, 'sum') + ': '),
                                text16Black(timesheet.totalMoneyEarned.toString() + ' PLN'),
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
            child: text20BlueBold(getTranslated(context, 'noTimesheets')),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Align(
            alignment: Alignment.center,
            child: textCenter19Black(getTranslated(context, 'noTimesheetsYet')),
          ),
        ),
      ],
    ),
  );
}
