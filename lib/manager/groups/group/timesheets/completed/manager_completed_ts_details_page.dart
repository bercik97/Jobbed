import 'dart:convert';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/employee/dto/employee_time_sheet_dto.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/dto/manager_group_employee_dto.dart';
import 'package:give_job/manager/dto/manager_group_time_sheet_dto.dart';
import 'package:give_job/manager/groups/group/employee/manager_employee_profile_page.dart';
import 'package:give_job/manager/groups/group/employee/manager_employee_ts_completed_page.dart';
import 'package:give_job/manager/groups/group/employee/model/group_employee_model.dart';
import 'package:give_job/manager/groups/group/shared/group_floating_action_button.dart';
import 'package:give_job/manager/service/manager_service.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/util/month_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/loader.dart';
import 'package:give_job/shared/widget/texts.dart';

import '../../../../manager_app_bar.dart';
import '../../../../manager_side_bar.dart';

class ManagerTimeSheetsEmployeesCompletedPage extends StatefulWidget {
  final GroupEmployeeModel _model;
  final ManagerGroupTimeSheetDto _timeSheet;

  ManagerTimeSheetsEmployeesCompletedPage(this._model, this._timeSheet);

  @override
  _ManagerTimeSheetsEmployeesCompletedPageState createState() =>
      _ManagerTimeSheetsEmployeesCompletedPageState();
}

class _ManagerTimeSheetsEmployeesCompletedPageState
    extends State<ManagerTimeSheetsEmployeesCompletedPage> {
  final ManagerService _managerService = new ManagerService();

  GroupEmployeeModel _model;
  ManagerGroupTimeSheetDto _timeSheet;

  List<ManagerGroupEmployeeDto> _employees = new List();
  List<ManagerGroupEmployeeDto> _filteredEmployees = new List();
  bool _loading = false;

  @override
  void initState() {
    this._model = widget._model;
    this._timeSheet = widget._timeSheet;
    super.initState();
    _loading = true;
    _managerService
        .findAllEmployeesOfTimeSheetByGroupIdAndTimeSheetYearMonthStatusForMobile(
            _model.groupId,
            _timeSheet.year,
            MonthUtil.findMonthNumberByMonthName(context, _timeSheet.month),
            STATUS_COMPLETED,
            _model.user.authHeader)
        .then((res) {
      setState(() {
        _employees = res;
        _filteredEmployees = _employees;
        _loading = false;
      });
    }).catchError((e) {
      ToastService.showBottomToast('Something went wrong', Colors.red);
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    this._model = widget._model;
    this._timeSheet = widget._timeSheet;
    if (_loading) {
      return loader(
        managerAppBar(context, null, getTranslated(context, 'loading')),
        managerSideBar(context, _model.user),
      );
    }
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: DARK,
        appBar: managerAppBar(
            context,
            _model.user,
            _timeSheet.year.toString() +
                ' ' +
                MonthUtil.translateMonth(context, _timeSheet.month) +
                ' - ' +
                STATUS_COMPLETED),
        drawer: managerSideBar(context, _model.user),
        body: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              child: TextFormField(
                autofocus: false,
                autocorrect: true,
                cursorColor: WHITE,
                style: TextStyle(color: WHITE),
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: WHITE, width: 2)),
                    counterStyle: TextStyle(color: WHITE),
                    border: OutlineInputBorder(),
                    labelText: 'Search',
                    prefixIcon: iconWhite(Icons.search),
                    labelStyle: TextStyle(color: WHITE)),
                onChanged: (string) {
                  setState(
                    () {
                      _filteredEmployees = _employees
                          .where((u) => (u.info
                              .toLowerCase()
                              .contains(string.toLowerCase())))
                          .toList();
                    },
                  );
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredEmployees.length,
                itemBuilder: (BuildContext context, int index) {
                  ManagerGroupEmployeeDto employee = _filteredEmployees[index];
                  String info = employee.info;
                  String nationality = employee.nationality;
                  String currency = employee.currency;
                  return Card(
                    color: DARK,
                    child: InkWell(
                      onTap: () {
                        EmployeeTimeSheetDto _completedTimeSheet =
                            new EmployeeTimeSheetDto(
                          id: _timeSheet.id,
                          year: _timeSheet.year,
                          month: _timeSheet.month,
                          groupName: _model.groupName,
                          groupCountryCurrency: currency,
                          status: _timeSheet.status,
                          numberOfHoursWorked: _filteredEmployees[index].numberOfHoursWorked,
                          averageRating: _filteredEmployees[index].averageRating,
                          amountOfEarnedMoney: _filteredEmployees[index].amountOfEarnedMoney,
                        );
                        Navigator.of(this.context).push(
                          CupertinoPageRoute<Null>(
                            builder: (BuildContext context) {
                              return ManagerEmployeeTsCompletedPage(
                                  _model,
                                  info,
                                  nationality,
                                  currency,
                                  _completedTimeSheet);
                            },
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            color: BRIGHTER_DARK,
                            child: ListTile(
                              trailing: Padding(
                                padding: EdgeInsets.all(4),
                                child: Transform.scale(
                                  scale: 1.2,
                                  child: BouncingWidget(
                                    duration: Duration(milliseconds: 100),
                                    scaleFactor: 1.5,
                                    onPressed: () {
                                      Navigator.push(
                                        this.context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ManagerEmployeeProfilePage(
                                                  _model,
                                                  nationality,
                                                  currency,
                                                  employee.id,
                                                  info),
                                        ),
                                      );
                                    },
                                    child: Image(
                                      image: AssetImage(
                                        'images/group-img.png', // TODO replace img
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              title: text20WhiteBold(
                                  utf8.decode(info.runes.toList()) +
                                      ' ' +
                                      LanguageUtil.findFlagByNationality(
                                          nationality)),
                              subtitle: Column(
                                children: <Widget>[
                                  Align(
                                      child: Row(
                                        children: <Widget>[
                                          textWhite(getTranslated(this.context,
                                                  'moneyPerHour') +
                                              ': '),
                                          textGreenBold(
                                              _filteredEmployees[index]
                                                      .moneyPerHour
                                                      .toString() +
                                                  ' ' +
                                                  currency),
                                        ],
                                      ),
                                      alignment: Alignment.topLeft),
                                  Align(
                                      child: Row(
                                        children: <Widget>[
                                          textWhite(getTranslated(this.context,
                                                  'averageRating') +
                                              ': '),
                                          textGreenBold(
                                              _filteredEmployees[index]
                                                  .averageRating
                                                  .toString()),
                                        ],
                                      ),
                                      alignment: Alignment.topLeft),
                                  Align(
                                      child: Row(
                                        children: <Widget>[
                                          textWhite(getTranslated(this.context,
                                                  'numberOfHoursWorked') +
                                              ': '),
                                          textGreenBold(
                                              _filteredEmployees[index]
                                                  .numberOfHoursWorked
                                                  .toString()),
                                        ],
                                      ),
                                      alignment: Alignment.topLeft),
                                  Align(
                                      child: Row(
                                        children: <Widget>[
                                          textWhite(getTranslated(this.context,
                                                  'amountOfEarnedMoney') +
                                              ': '),
                                          textGreenBold(
                                              _filteredEmployees[index]
                                                      .amountOfEarnedMoney
                                                      .toString() +
                                                  ' ' +
                                                  currency),
                                        ],
                                      ),
                                      alignment: Alignment.topLeft),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: groupFloatingActionButton(context, _model),
      ),
    );
  }
}
