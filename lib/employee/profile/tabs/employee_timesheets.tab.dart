import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:give_job/employee/profile/timesheet/employee_timesheet_page.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/util/month_util.dart';
import 'package:give_job/shared/widget/texts.dart';

Widget employeeTimesheetsTab(BuildContext context, User user, List timesheets) {
  if (timesheets.isEmpty) {
    return _handleEmptyData(context);
  }
  return Container(
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            for (var timesheet in timesheets)
              Card(
                color: BRIGHTER_DARK,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute<Null>(
                            builder: (BuildContext context) {
                              return EmployeeTimesheetPage(user, timesheet);
                            },
                          ),
                        );
                      },
                      child: ListTile(
                        leading: Padding(
                          padding: EdgeInsets.only(bottom: 15),
                          child: Image(
                            image: timesheet.status == STATUS_IN_PROGRESS ? AssetImage('images/unchecked.png') : AssetImage('images/checked.png'),
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                        title: textWhiteBold(timesheet.year.toString() + ' ' + MonthUtil.translateMonth(context, timesheet.month) + '\n' + utf8.decode(timesheet.groupName.runes.toList())),
                        subtitle: Column(
                          children: <Widget>[
                            Align(
                                child: Row(
                                  children: <Widget>[
                                    textWhite(getTranslated(context, 'hours') + ': '),
                                    textGreenBold(timesheet.numberOfHoursWorked.toString()),
                                  ],
                                ),
                                alignment: Alignment.topLeft),
                            Align(
                                child: Row(
                                  children: <Widget>[
                                    textWhite(getTranslated(context, 'averageRating') + ': '),
                                    textGreenBold(timesheet.averageRating.toString()),
                                  ],
                                ),
                                alignment: Alignment.topLeft),
                          ],
                        ),
                        trailing: Wrap(
                          children: <Widget>[textGreenBold(timesheet.amountOfEarnedMoney.toString()), textGreenBold(" " + timesheet.groupCountryCurrency.toString())],
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
