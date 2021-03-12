import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jobbed/api/employee/dto/employee_profile_dto.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/util/workday_util.dart';
import 'package:jobbed/shared/widget/buttons.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';

Widget employeeToday(BuildContext context, EmployeeProfileDto dto, Function() fillHoursFun) {
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
                child: textCenter20BlueBold(getTranslated(context, 'youDontHaveTsForCurrentMonth')),
              ),
            ),
          ],
        ),
      ),
    );
  }
  return Column(
    children: [
      _buildStatisticsContainer(context, dto, fillHoursFun),
    ],
  );
}

Widget _buildStatisticsContainer(BuildContext context, EmployeeProfileDto dto, Function() fillHoursFun) {
  String todayDate = dto.todayDate;
  String todayMoney = dto.todayMoney.toString();
  String todayHours = dto.todayHours.toString();
  List todayPiecework = dto.todayPiecework;
  List todayWorkTimes = dto.todayWorkTimes;
  bool canFillHours = dto.canFillHours;
  return Container(
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            Ink(
              color: BRIGHTER_BLUE,
              child: ListTile(
                trailing: todayMoney != '0.000' ? icon50Green(Icons.check) : icon50Red(Icons.close),
                title: Column(
                  children: <Widget>[
                    SizedBox(height: 5),
                    Align(
                        child: Row(
                          children: <Widget>[
                            text15Black(getTranslated(context, 'hours') + ': '),
                            text15BlueBold(todayHours),
                          ],
                        ),
                        alignment: Alignment.topLeft),
                    SizedBox(height: 5),
                    Align(
                        child: Row(
                          children: <Widget>[
                            text15Black(getTranslated(context, 'accord') + ': '),
                            todayPiecework != null && todayPiecework.isNotEmpty
                                ? Row(
                                    children: [
                                      text15BlueBold(getTranslated(context, 'yes') + ' '),
                                      iconBlue(Icons.search),
                                      textBlue('(' + getTranslated(context, 'checkingDetails') + ')'),
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
                            text15Black(getTranslated(context, 'time') + ': '),
                            todayWorkTimes != null && todayWorkTimes.isNotEmpty
                                ? Row(
                                    children: [
                                      text15BlueBold(getTranslated(context, 'yes') + ' '),
                                      iconBlue(Icons.search),
                                      textBlue('(' + getTranslated(context, 'checkingDetails') + ')'),
                                    ],
                                  )
                                : text15RedBold(getTranslated(context, 'empty'))
                          ],
                        ),
                        alignment: Alignment.topLeft),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        text15Black(getTranslated(context, 'money') + ' (' + getTranslated(context, 'sum') + '): '),
                        text15BlueBold(todayMoney + ' PLN'),
                      ],
                    ),
                    SizedBox(height: 5),
                  ],
                ),
                onTap: () => WorkdayUtil.showScrollableWorkTimes(context, todayDate, todayPiecework, todayWorkTimes),
              ),
            ),
            canFillHours
                ? Column(
                    children: [
                      SizedBox(height: 10),
                      Buttons.standardButton(
                        minWidth: 200.0,
                        color: BLUE,
                        title: getTranslated(context, 'fillHours'),
                        fun: () => fillHoursFun(),
                      ),
                    ],
                  )
                : SizedBox(height: 10),
          ],
        ),
      ),
    ),
  );
}
