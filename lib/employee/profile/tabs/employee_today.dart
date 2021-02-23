import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:give_job/api/employee/dto/employee_profile_dto.dart';
import 'package:give_job/shared/util/workday_employee_util.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/widget/buttons.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';

Container employeeToday(BuildContext context, EmployeeProfileDto dto, Function() fillHoursFun, Function() editNoteFun) {
  bool isTsNotCreated = dto.todayWorkdayId == 0;
  if (isTsNotCreated) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: Align(
                alignment: Alignment.center,
                child: textCenter20GreenBold(getTranslated(context, 'youDontHaveTsForCurrentMonth')),
              ),
            ),
          ],
        ),
      ),
    );
  }
  String todayDate = dto.todayDate;
  String todayMoney = dto.todayMoney.toString();
  String todayHours = dto.todayHours.toString();
  List todayPiecework = dto.todayPiecework;
  List todayWorkTimes = dto.todayWorkTimes;
  String todayNote = dto.todayNote;
  bool canFillHours = dto.canFillHours;
  return Container(
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            Ink(
              color: BRIGHTER_DARK,
              child: ListTile(
                trailing: todayMoney != '0.000' ? icon50Green(Icons.check) : icon50Red(Icons.close),
                title: Column(
                  children: <Widget>[
                    SizedBox(height: 5),
                    Align(
                        child: Row(
                          children: <Widget>[
                            text15White(getTranslated(context, 'hours') + ': '),
                            text15GreenBold(todayHours),
                          ],
                        ),
                        alignment: Alignment.topLeft),
                    SizedBox(height: 5),
                    Align(
                        child: Row(
                          children: <Widget>[
                            text15White(getTranslated(context, 'accord') + ': '),
                            todayPiecework != null && todayPiecework.isNotEmpty
                                ? Row(
                                    children: [
                                      text15GreenBold(getTranslated(context, 'yes') + ' '),
                                      iconGreen(Icons.search),
                                      textGreen('(' + getTranslated(context, 'checkingDetails') + ')'),
                                    ],
                                  )
                                : text15RedBold(getTranslated(context, 'empty'))
                          ],
                        ),
                        alignment: Alignment.topLeft),
                    SizedBox(height: 5),
                    Align(
                        child: Row(
                          children: <Widget>[
                            text15White(getTranslated(context, 'time') + ': '),
                            todayWorkTimes != null && todayWorkTimes.isNotEmpty
                                ? Row(
                                    children: [
                                      text15GreenBold(getTranslated(context, 'yes') + ' '),
                                      iconGreen(Icons.search),
                                      textGreen('(' + getTranslated(context, 'checkingDetails') + ')'),
                                    ],
                                  )
                                : text15RedBold(getTranslated(context, 'empty'))
                          ],
                        ),
                        alignment: Alignment.topLeft),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        text15White(getTranslated(context, 'money') + ' (' + getTranslated(context, 'sum') + '): '),
                        text15GreenBold(todayMoney + ' PLN'),
                      ],
                    ),
                    SizedBox(height: 5),
                    Align(
                        child: Row(
                          children: <Widget>[
                            text15White(getTranslated(context, 'note') + ': '),
                            todayNote != null && todayNote.isNotEmpty
                                ? Row(
                                    children: [
                                      text15GreenBold(getTranslated(context, 'yes') + ' '),
                                      iconGreen(Icons.search),
                                      textGreen('(' + getTranslated(context, 'checkingDetails') + ')'),
                                    ],
                                  )
                                : text15RedBold(getTranslated(context, 'empty'))
                          ],
                        ),
                        alignment: Alignment.topLeft),
                    SizedBox(height: 5),
                  ],
                ),
                onTap: () => WorkdayEmployeeUtil.showScrollableWorkTimesAndNote(context, todayDate, todayPiecework, todayWorkTimes, todayNote),
              ),
            ),
            canFillHours
                ? Column(
                    children: [
                      SizedBox(height: 10),
                      Buttons.standardButton(
                        minWidth: 200.0,
                        color: GREEN,
                        title: getTranslated(context, 'fillHours'),
                        fun: () => fillHoursFun(),
                      ),
                    ],
                  )
                : SizedBox(height: 10),
            Buttons.standardButton(
              minWidth: 200.0,
              color: GREEN,
              title: getTranslated(context, 'editNote'),
              fun: () => editNoteFun(),
            ),
          ],
        ),
      ),
    ),
  );
}
