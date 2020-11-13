import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/api/employee/dto/employee_page_dto.dart';
import 'package:give_job/employee/profile/tabs/calendar/employee_calendar_page.dart';
import 'package:give_job/employee/profile/tabs/worktime/work_time_page.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/widget/texts.dart';

import 'contact/contact_for_manager.dart';

Container employeePanel(BuildContext context, User user, EmployeePageDto employee) {
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
                      onTap: () {
                        int todayWorkdayId = employee.todayWorkdayId;
                        if (todayWorkdayId == 0) {
                          ToastService.showErrorToast(getTranslated(context, 'cannotStartWorkWithoutTS'));
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => WorkTimePage(user, employee.todayWorkdayId)),
                        );
                      },
                      child: _buildScrollableContainer(context, 'images/big-employee-work-icon.png', 'workingTime', 'startFinishWork'),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Material(
                    color: BRIGHTER_DARK,
                    child: InkWell(
                      onTap: () => employee.groupManager != null
                          ? showContactForManager(
                              context,
                              employee.groupManager,
                              employee.groupManagerPhone,
                              employee.groupManagerViber,
                              employee.groupManagerWhatsApp,
                            )
                          : ToastService.showErrorToast(getTranslated(context, 'noManagerAssigned')),
                      child: _buildScrollableContainer(context, 'images/big-contact-with-manager-icon.png', 'contact', 'contactWithYourManager'),
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
                      onTap: () => Navigator.of(context).push(
                        CupertinoPageRoute<Null>(
                          builder: (BuildContext context) {
                            return EmployeeCalendarPage(user, employee.id);
                          },
                        ),
                      ),
                      child: _buildScrollableContainer(context, 'images/big-documents-icon.png', 'calendar', 'checkYourCalendar'),
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
    height: 160,
    child: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: <Widget>[
          Image(height: 100, image: AssetImage(imagePath)),
          text18WhiteBold(getTranslated(context, title)),
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
