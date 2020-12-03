import 'dart:convert';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/api/employee/dto/employee_statistics_dto.dart';
import 'package:give_job/api/employee/service/employee_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:give_job/api/timesheet/dto/timesheet_with_status_dto.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/employee/employee_profil_page.dart';
import 'package:give_job/manager/groups/group/employee/employee_ts_completed_page.dart';
import 'package:give_job/manager/shared/group_model.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/util/avatars_util.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/util/month_util.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';

import '../../../../../shared/widget/loader.dart';
import '../../../../shared/manager_app_bar.dart';
import '../../../../shared/manager_side_bar.dart';
import '../ts_page.dart';

class TsCompletedPage extends StatefulWidget {
  final GroupModel _model;
  final TimesheetWithStatusDto _timesheet;

  TsCompletedPage(this._model, this._timesheet);

  @override
  _TsCompletedPageState createState() => _TsCompletedPageState();
}

class _TsCompletedPageState extends State<TsCompletedPage> {
  GroupModel _model;
  User _user;

  EmployeeService _employeeService;
  TimesheetWithStatusDto _timesheet;

  List<EmployeeStatisticsDto> _employees = new List();
  List<EmployeeStatisticsDto> _filteredEmployees = new List();
  bool _loading = false;

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._employeeService = ServiceInitializer.initialize(context, _user.authHeader, EmployeeService);
    this._timesheet = widget._timesheet;
    super.initState();
    _loading = true;
    _employeeService
        .findAllByGroupIdAndTsYearAndMonthAndStatus(
      _model.groupId,
      _timesheet.year,
      MonthUtil.findMonthNumberByMonthName(context, _timesheet.month),
      STATUS_COMPLETED,
    )
        .then((res) {
      setState(() {
        _employees = res;
        _filteredEmployees = _employees;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    this._model = widget._model;
    this._timesheet = widget._timesheet;
    if (_loading) {
      return loader(managerAppBar(context, _model.user, getTranslated(context, 'loading')), managerSideBar(context, _model.user));
    }
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: DARK,
          appBar: managerAppBar(
            context,
            _model.user,
            _timesheet.year.toString() + ' ' + MonthUtil.translateMonth(context, _timesheet.month) + ' - ' + getTranslated(context, STATUS_COMPLETED),
          ),
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
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
                    counterStyle: TextStyle(color: WHITE),
                    border: OutlineInputBorder(),
                    labelText: getTranslated(context, 'search'),
                    prefixIcon: iconWhite(Icons.search),
                    labelStyle: TextStyle(color: WHITE),
                  ),
                  onChanged: (string) {
                    setState(
                      () {
                        _filteredEmployees = _employees.where((u) => (u.info.toLowerCase().contains(string.toLowerCase()))).toList();
                      },
                    );
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredEmployees.length,
                  itemBuilder: (BuildContext context, int index) {
                    EmployeeStatisticsDto employee = _filteredEmployees[index];
                    String info = employee.info;
                    String nationality = employee.nationality;
                    String currency = employee.currency;
                    String avatarPath = AvatarsUtil.getAvatarPathByLetter(employee.gender, info.substring(0, 1));
                    return Card(
                      color: DARK,
                      child: InkWell(
                        onTap: () {
                          TimesheetForEmployeeDto _completedTimesheet = new TimesheetForEmployeeDto(
                            id: _timesheet.id,
                            year: _timesheet.year,
                            month: _timesheet.month,
                            companyName: null,
                            groupName: _model.groupName,
                            groupCountryCurrency: currency,
                            status: _timesheet.status,
                            numberOfHoursWorked: _filteredEmployees[index].numberOfHoursWorked,
                            averageRating: _filteredEmployees[index].averageRating,
                            amountOfEarnedMoney: _filteredEmployees[index].amountOfEarnedMoney,
                          );
                          Navigator.of(this.context).push(
                            CupertinoPageRoute<Null>(
                              builder: (BuildContext context) {
                                return EmployeeTsCompletedPage(_model, info, nationality, currency, _completedTimesheet);
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
                                            builder: (context) => EmployeeProfilPage(_model, nationality, currency, employee.id, info, avatarPath, TsCompletedPage(_model, _timesheet)),
                                          ),
                                        );
                                      },
                                      child: Image(
                                        image: AssetImage(avatarPath),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                title: text20WhiteBold(utf8.decode(info.runes.toList()) + ' ' + LanguageUtil.findFlagByNationality(nationality)),
                                subtitle: Column(
                                  children: <Widget>[
                                    Align(
                                        child: Row(
                                          children: <Widget>[
                                            textWhite(getTranslated(this.context, 'averageRating') + ': '),
                                            textGreenBold(_filteredEmployees[index].averageRating.toString()),
                                          ],
                                        ),
                                        alignment: Alignment.topLeft),
                                    Align(
                                        child: Row(
                                          children: <Widget>[
                                            textWhite(getTranslated(this.context, 'numberOfHoursWorked') + ': '),
                                            textGreenBold(_filteredEmployees[index].numberOfHoursWorked.toString()),
                                          ],
                                        ),
                                        alignment: Alignment.topLeft),
                                    Align(
                                        child: Row(
                                          children: <Widget>[
                                            textWhite(getTranslated(this.context, 'amountOfEarnedMoney') + ': '),
                                            textGreenBold(_filteredEmployees[index].amountOfEarnedMoney.toString() + ' ' + currency),
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
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, ManagerTsPage(_model)),
    );
  }
}
