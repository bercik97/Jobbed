import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:give_job/api/employee/dto/employee_page_dto.dart';
import 'package:give_job/api/workday/util/workday_util.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';

Container employeeToday(BuildContext context, EmployeePageDto dto, Function() fillHoursFun, Function() editNoteFun) {
  bool isTsNotCreated = dto.todayWorkdayId == 0;
  if (isTsNotCreated) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10),
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
  String todayRating = dto.todayRating.toString();
  String todayPlan = dto.todayPlan;
  String todayNote = dto.todayNote;
  return Container(
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            Align(alignment: Alignment.center, child: text20GreenBold(todayDate)),
            SizedBox(height: 10),
            Ink(
              color: BRIGHTER_DARK,
              child: ListTile(
                trailing: todayHours != '0' ? icon50Green(Icons.check) : icon50Red(Icons.close),
                title: Row(
                  children: [
                    text15White(getTranslated(context, 'amountOfEarnedMoney') + ': '),
                    text15GreenBold(todayMoney),
                  ],
                ),
                subtitle: Column(
                  children: <Widget>[
                    SizedBox(height: 5),
                    Align(
                        child: Row(
                          children: <Widget>[
                            text15White(getTranslated(context, 'numberOfHoursWorked') + ': '),
                            text15GreenBold(todayHours),
                          ],
                        ),
                        alignment: Alignment.topLeft),
                    SizedBox(height: 5),
                    Align(
                        child: Row(
                          children: <Widget>[
                            text15White(getTranslated(context, 'rating') + ': '),
                            text15GreenBold(todayRating + ' / 10'),
                          ],
                        ),
                        alignment: Alignment.topLeft),
                    SizedBox(height: 5),
                    Align(
                        child: Row(
                          children: <Widget>[
                            text15White(getTranslated(context, 'plan') + ': '),
                            todayPlan != null && todayPlan.isNotEmpty
                                ? Row(
                                    children: [
                                      text15GreenBold(getTranslated(context, 'yes') + ' '),
                                      iconGreen(Icons.search),
                                      textGreen('(' + getTranslated(context, 'checkDetails') + ')'),
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
                            text15White(getTranslated(context, 'note') + ': '),
                            todayNote != null && todayNote.isNotEmpty
                                ? Row(
                                    children: [
                                      text15GreenBold(getTranslated(context, 'yes') + ' '),
                                      iconGreen(Icons.search),
                                      textGreen('(' + getTranslated(context, 'checkDetails') + ')'),
                                    ],
                                  )
                                : text15RedBold(getTranslated(context, 'empty'))
                          ],
                        ),
                        alignment: Alignment.topLeft),
                    SizedBox(height: 2.5),
                  ],
                ),
                onTap: () => WorkdayUtil.showScrollablePlanAndNote(context, todayDate, todayPlan, todayNote),
              ),
            ),
            SizedBox(height: 10),
            MaterialButton(
              color: GREEN,
              child: Text(getTranslated(context, 'fillHours')),
              onPressed: () => fillHoursFun(),
            ),
            MaterialButton(
              color: GREEN,
              child: Text(getTranslated(context, 'editNote')),
              onPressed: () => editNoteFun(),
            ),
          ],
        ),
      ),
    ),
  );
}
