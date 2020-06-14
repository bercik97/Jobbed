import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:give_job/employee/dto/employee_time_sheet_dto.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/manager_readonly_employee_time_sheet_page.dart';
import 'package:give_job/manager/service/manager_service.dart';
import 'package:give_job/shared/app_bar.dart';
import 'package:give_job/shared/toastr_service.dart';

import '../shared/constants.dart';
import 'manager_side_bar.dart';

class ManagerEmployeeTimeSheetsPage extends StatefulWidget {
  final String _managerId;
  final String _managerInfo;
  final String _authHeader;

  final int _groupId;
  final int _employeeId;
  final String _employeeInfo;

  const ManagerEmployeeTimeSheetsPage(this._managerId, this._managerInfo,
      this._authHeader, this._groupId, this._employeeId, this._employeeInfo);

  @override
  _ManagerEmployeeTimeSheetsPageState createState() =>
      _ManagerEmployeeTimeSheetsPageState();
}

class _ManagerEmployeeTimeSheetsPageState
    extends State<ManagerEmployeeTimeSheetsPage> {
  final ManagerService _managerService = new ManagerService();

  String translateMonth(String toTranslate) {
    switch (toTranslate) {
      case JANUARY:
        return getTranslated(context, 'january');
      case FEBRUARY:
        return getTranslated(context, 'february');
      case MARCH:
        return getTranslated(context, 'march');
      case APRIL:
        return getTranslated(context, 'april');
      case MAY:
        return getTranslated(context, 'may');
      case JUNE:
        return getTranslated(context, 'june');
      case JULY:
        return getTranslated(context, 'july');
      case AUGUST:
        return getTranslated(context, 'august');
      case SEPTEMBER:
        return getTranslated(context, 'september');
      case OCTOBER:
        return getTranslated(context, 'october');
      case NOVEMBER:
        return getTranslated(context, 'november');
      case DECEMBER:
        return getTranslated(context, 'december');
    }
    throw 'Wrong month to translate!';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EmployeeTimeSheetDto>>(
      future: _managerService
          .findEmployeeTimeSheetsByGroupIdAndEmployeeId(
              widget._groupId.toString(),
              widget._employeeId.toString(),
              widget._authHeader)
          .catchError((e) {
        ToastService.showToast(
            getTranslated(context, 'employeeDoesNotHaveTimeSheets'),
            Colors.red);
        Navigator.pop(context);
      }),
      builder: (BuildContext context,
          AsyncSnapshot<List<EmployeeTimeSheetDto>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        } else {
          List<EmployeeTimeSheetDto> timeSheets = snapshot.data;
          if (timeSheets.isEmpty) {
            ToastService.showToast(
                getTranslated(context, 'employeeDoesNotHaveTimeSheets'),
                Colors.red);
            Navigator.pop(context);
          }
          return MaterialApp(
            title: APP_NAME,
            theme: ThemeData(
              primarySwatch: Colors.green,
            ),
            home: Scaffold(
              appBar: appBar(context, getTranslated(context, 'workTimeSheets')),
              drawer: managerSideBar(context, widget._managerId,
                  widget._managerInfo, widget._authHeader),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        widget._employeeInfo != null
                            ? 'Arkusze czasu pracownika: ' +
                                utf8.decode(widget._employeeInfo.runes.toList())
                            : getTranslated(context, 'empty'),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      for (var timeSheet in timeSheets)
                        Card(
                          child: InkWell(
                            onTap: () {
                              if (timeSheet.status == 'Accepted') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ManagerReadonlyEmployeeTimeSheetPage(
                                            widget._managerId,
                                            widget._managerInfo,
                                            widget._authHeader,
                                            widget._employeeInfo,
                                            timeSheet),
                                  ),
                                );
                              } else {
                                /* to be implemented */
                              }
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                ListTile(
                                  leading: Icon(
                                    timeSheet.status == 'Accepted'
                                        ? Icons.check_circle_outline
                                        : Icons.radio_button_unchecked,
                                    color: timeSheet.status == 'Accepted'
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                  title: Text(timeSheet.year.toString() +
                                      ' ' +
                                      translateMonth(timeSheet.month) +
                                      '\n' +
                                      utf8.decode(
                                          timeSheet.groupName.runes.toList())),
                                  subtitle: Wrap(
                                    children: <Widget>[
                                      Text(getTranslated(
                                              context, 'hoursWorked') +
                                          ': ' +
                                          timeSheet.totalHours.toString() +
                                          'h'),
                                      Text(getTranslated(
                                              context, 'averageRating') +
                                          ': ' +
                                          timeSheet.averageEmployeeRating
                                              .toString()),
                                    ],
                                  ),
                                  trailing: Wrap(
                                    children: <Widget>[
                                      Text(
                                        timeSheet.totalMoneyEarned.toString(),
                                        style: TextStyle(
                                            color: Colors.green, fontSize: 20),
                                      ),
                                      Icon(
                                        Icons.attach_money,
                                        color: Colors.green,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
