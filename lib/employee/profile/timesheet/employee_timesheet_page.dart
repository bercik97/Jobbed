import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/employee/dto/employee_timesheet_dto.dart';
import 'package:give_job/employee/dto/employee_workday_dto.dart';
import 'package:give_job/employee/employee_app_bar.dart';
import 'package:give_job/employee/employee_side_bar.dart';
import 'package:give_job/employee/profile/employee_profil_page.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/util/month_util.dart';
import 'package:give_job/shared/widget/circular_progress_indicator.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:give_job/shared/workdays/workday_service.dart';
import 'package:give_job/shared/workdays/workday_util.dart';

class EmployeeTimesheetPage extends StatefulWidget {
  final User _user;
  final EmployeeTimesheetDto _timesheet;

  EmployeeTimesheetPage(this._user, this._timesheet);

  @override
  _EmployeeTimesheetPageState createState() => _EmployeeTimesheetPageState();
}

class _EmployeeTimesheetPageState extends State<EmployeeTimesheetPage> {
  User _user;
  SharedWorkdayService _sharedWorkdayService;
  EmployeeTimesheetDto _timesheet;

  @override
  Widget build(BuildContext context) {
    this._user = widget._user;
    this._sharedWorkdayService =
        new SharedWorkdayService(context, _user.authHeader);
    this._timesheet = widget._timesheet;
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: DARK,
        appBar: employeeAppBar(
            context,
            _user,
            getTranslated(context, 'workdays') +
                ' - ' +
                getTranslated(context, _timesheet.status)),
        drawer: employeeSideBar(context, _user),
        body: Column(
          children: <Widget>[
            Container(
              color: BRIGHTER_DARK,
              child: Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: ListTile(
                  leading: Padding(
                    padding: EdgeInsets.only(bottom: 15),
                    child: Image(
                      image: _timesheet.status == STATUS_COMPLETED
                          ? AssetImage('images/checked.png')
                          : AssetImage('images/unchecked.png'),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  title: textWhiteBold(_timesheet.year.toString() +
                      ' ' +
                      MonthUtil.translateMonth(context, _timesheet.month)),
                  subtitle: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: textWhiteBold(_user.info != null
                            ? utf8.decode(_user.info.runes.toList()) +
                                ' ' +
                                LanguageUtil.findFlagByNationality(
                                    _user.nationality)
                            : getTranslated(context, 'empty')),
                      ),
                      Row(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: textWhite(
                                getTranslated(context, 'hours') + ': '),
                          ),
                          textGreenBold(
                              _timesheet.numberOfHoursWorked.toString() + 'h'),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: textWhite(
                                getTranslated(context, 'averageRating') + ': '),
                          ),
                          textGreenBold(
                              widget._timesheet.averageRating.toString()),
                        ],
                      ),
                    ],
                  ),
                  trailing: Wrap(
                    children: <Widget>[
                      text20GreenBold(
                          _timesheet.amountOfEarnedMoney.toString()),
                      text20GreenBold(' ' + _timesheet.groupCountryCurrency),
                    ],
                  ),
                ),
              ),
            ),
            FutureBuilder(
              future: _sharedWorkdayService
                  .findEmployeeWorkdaysByTimesheetId(_timesheet.id.toString()),
              builder: (BuildContext context,
                  AsyncSnapshot<List<EmployeeWorkdayDto>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.data == null) {
                  return Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: circularProgressIndicator(),
                  );
                } else {
                  List<EmployeeWorkdayDto> workdays = snapshot.data;
                  return Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Theme(
                          data: Theme.of(this.context)
                              .copyWith(dividerColor: MORE_BRIGHTER_DARK),
                          child: DataTable(
                            columnSpacing: 40,
                            columns: [
                              DataColumn(label: textWhiteBold('No.')),
                              DataColumn(
                                  label: textWhiteBold(
                                      getTranslated(this.context, 'hours'))),
                              DataColumn(
                                  label: textWhiteBold(
                                      getTranslated(this.context, 'money'))),
                              DataColumn(
                                  label: textWhiteBold(
                                      getTranslated(this.context, 'plan'))),
                              DataColumn(
                                  label: textWhiteBold(getTranslated(
                                      this.context, 'workplace'))),
                            ],
                            rows: [
                              for (var workday in workdays)
                                DataRow(
                                  cells: [
                                    DataCell(
                                        textWhite(workday.number.toString())),
                                    DataCell(
                                        textWhite(workday.hours.toString())),
                                    DataCell(
                                        textWhite(workday.money.toString())),
                                    DataCell(
                                        Wrap(
                                          children: <Widget>[
                                            workday.plan != null &&
                                                    workday.plan != ''
                                                ? iconWhite(Icons.zoom_in)
                                                : textWhiteBold('-'),
                                          ],
                                        ),
                                        onTap: () =>
                                            WorkdayUtil.showScrollableDialog(
                                                this.context,
                                                getTranslated(this.context,
                                                    'planDetails'),
                                                workday.plan)),
                                    DataCell(
                                        Wrap(
                                          children: <Widget>[
                                            workday.workplaceName != null &&
                                                    workday.workplaceName != ''
                                                ? iconWhite(Icons.zoom_in)
                                                : textWhiteBold('-'),
                                          ],
                                        ),
                                        onTap: () =>
                                            WorkdayUtil.showScrollableDialog(
                                                this.context,
                                                getTranslated(
                                                    this.context, 'workplace'),
                                                workday.workplaceName)),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              this.context,
              MaterialPageRoute(
                  builder: (context) => EmployeeProfilPage(_user)),
            );
          },
          child: Image(
            height: 50,
            image: AssetImage('images/big-employee-icon.png'),
          ),
          backgroundColor: BRIGHTER_DARK,
        ),
      ),
    );
  }
}
