import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jobbed/api/employee/dto/employee_profile_dto.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/workday_util.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';

Widget employeeToday(BuildContext context, User user, EmployeeProfileDto dto) {
  bool isTsNotCreated = dto.todayWorkdayId == 0;
  if (isTsNotCreated) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.center,
          child: textCenter20BlueBold(getTranslated(context, 'youDontHaveTsForCurrentMonth')),
        ),
      ),
    );
  }
  String todayDate = dto.todayDate;
  String todayMoneyForTime = dto.todayMoneyForTime.toString();
  String todayMoneyForPiecework = dto.todayMoneyForPiecework.toString();
  String todayMoney = dto.todayMoney.toString();
  List todayWorkTimes = dto.todayWorkTimes;
  List todayPiecework = dto.todayPiecework;
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            trailing: todayMoney != '0.000' ? icon50Green(Icons.check) : icon50Red(Icons.close),
            subtitle: Column(
              children: <Widget>[
                SizedBox(height: 7.5),
                Align(
                    child: Row(
                      children: <Widget>[
                        text17Black(getTranslated(context, 'workTime') + ': '),
                        text17GreenBold(todayMoneyForTime + ' PLN '),
                        todayWorkTimes != null && todayWorkTimes.isNotEmpty
                            ? IconButton(
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                icon: icon30Black(Icons.zoom_in),
                                onPressed: () => WorkdayUtil.showScrollableWorkTimes(context, todayDate, todayWorkTimes),
                              )
                            : SizedBox(height: 0),
                      ],
                    ),
                    alignment: Alignment.topLeft),
                SizedBox(height: 5),
                Align(
                    child: Row(
                      children: <Widget>[
                        text17Black(getTranslated(context, 'accord') + ': '),
                        text17GreenBold(todayMoneyForPiecework + ' PLN '),
                        todayPiecework != null && todayPiecework.isNotEmpty
                            ? IconButton(
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                icon: icon30Black(Icons.zoom_in),
                                onPressed: () => WorkdayUtil.showScrollablePieceworks(context, todayDate, todayPiecework),
                              )
                            : SizedBox(width: 0),
                      ],
                    ),
                    alignment: Alignment.topLeft),
                SizedBox(height: 5),
                Align(
                    child: Row(
                      children: <Widget>[
                        text17Black(getTranslated(context, 'sum') + ': '),
                        text17GreenBold(todayMoney + ' PLN'),
                      ],
                    ),
                    alignment: Alignment.topLeft),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
