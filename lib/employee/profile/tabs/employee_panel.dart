import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/employee/dto/employee_dto.dart';
import 'package:give_job/employee/profile/tabs/calendar/employee_calendar_page.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';

import 'contact/manager_contact.dart';

Container employeePanel(BuildContext context, User user, EmployeeDto employee) {
  String manager = employee.groupManager;
  String managerEmail = employee.groupManagerEmail;
  String managerPhone = employee.groupManagerPhone;
  String managerViber = employee.groupManagerViber;
  String managerWhatsApp = employee.groupManagerWhatsApp;
  EmployeeCalendarPage page = new EmployeeCalendarPage();
  page.employeeId = employee.id;
  page.user = user;
  return Container(
    child: SingleChildScrollView(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Material(
              color: BRIGHTER_DARK,
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  CupertinoPageRoute<Null>(
                    builder: (BuildContext context) {
                      return page;
                    },
                  ),
                ),
                child: _buildScrollableContainer(
                    context, Icons.today, 'calendar', 'checkYourCalendar'),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Material(
              color: BRIGHTER_DARK,
              child: InkWell(
                onTap: () => showManagerContact(context, manager, managerEmail,
                    managerPhone, managerViber, managerWhatsApp),
                child: _buildScrollableContainer(
                    context, Icons.phone, 'contact', 'contactWithYourManager'),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildScrollableContainer(
    BuildContext context, IconData icon, String title, String subtitle) {
  return Container(
    height: 120,
    child: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: <Widget>[
          SizedBox(height: 10),
          icon50Green(icon),
          text18WhiteBold(getTranslated(context, title)),
          Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: textCenter13White(getTranslated(context, subtitle))),
          SizedBox(height: 10)
        ],
      ),
    ),
  );
}
