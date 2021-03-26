import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jobbed/api/employee/dto/employee_statistics_dto.dart';
import 'package:jobbed/api/employee/service/employee_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:jobbed/api/timesheet/dto/timesheet_with_status_dto.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/groups/group/employee/employee_profile_page.dart';
import 'package:jobbed/manager/groups/group/employee/employee_ts_completed_page.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/avatars_util.dart';
import 'package:jobbed/shared/util/language_util.dart';
import 'package:jobbed/shared/util/month_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';

import '../../../../shared/manager_app_bar.dart';

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
    _employeeService.findAllByGroupIdAndTsYearAndMonthAndStatusForStatisticsView(_model.groupId, _timesheet.year, MonthUtil.findMonthNumberByMonthName(context, _timesheet.month), STATUS_COMPLETED).then((res) {
      setState(() {
        _employees = res;
        _filteredEmployees = _employees;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WHITE,
      appBar: managerAppBar(context, _model.user, getTranslated(context, 'timesheets'), () => Navigator.pop(context)),
      body: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 15, left: 15, bottom: 10),
              child: text20GreenBold(_timesheet.year.toString() + ' ' + MonthUtil.translateMonth(context, _timesheet.month) + ' → ' + getTranslated(context, STATUS_COMPLETED)),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: TextFormField(
              autofocus: false,
              autocorrect: true,
              cursorColor: BLACK,
              style: TextStyle(color: BLACK),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: BLACK, width: 2)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: BLUE, width: 2)),
                counterStyle: TextStyle(color: BLACK),
                border: OutlineInputBorder(),
                labelText: getTranslated(context, 'search'),
                prefixIcon: iconBlack(Icons.search),
                labelStyle: TextStyle(color: BLACK),
              ),
              onChanged: (string) {
                setState(
                  () {
                    _filteredEmployees = _employees.where((u) => ((u.name + u.surname).toLowerCase().contains(string.toLowerCase()))).toList();
                  },
                );
              },
            ),
          ),
          _loading
              ? circularProgressIndicator()
              : Expanded(
                  child: ListView.builder(
                    itemCount: _filteredEmployees.length,
                    itemBuilder: (BuildContext context, int index) {
                      EmployeeStatisticsDto employee = _filteredEmployees[index];
                      String name = employee.name;
                      String surname = employee.surname;
                      String gender = employee.gender;
                      String nationality = employee.nationality;
                      return Card(
                        color: WHITE,
                        child: InkWell(
                          onTap: () {
                            TimesheetForEmployeeDto _completedTimesheet = new TimesheetForEmployeeDto(
                              id: employee.timesheetId,
                              year: _timesheet.year,
                              month: _timesheet.month,
                              status: _timesheet.status,
                              totalHours: _filteredEmployees[index].totalHours,
                              totalTime: _filteredEmployees[index].totalTime,
                              totalMoneyForPieceworkForEmployee: _filteredEmployees[index].totalMoneyForPieceworkForEmployee,
                              totalMoneyForTimeForEmployee: _filteredEmployees[index].totalMoneyForTimeForEmployee,
                              totalMoneyEarned: _filteredEmployees[index].totalMoneyEarned,
                              employeeBasicDto: null,
                            );
                            NavigatorUtil.navigate(this.context, EmployeeTsCompletedPage(_model, name, surname, nationality, _completedTimesheet));
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                color: BRIGHTER_BLUE,
                                child: ListTile(
                                  trailing: Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Transform.scale(
                                      scale: 1.2,
                                      child: BouncingWidget(
                                        duration: Duration(milliseconds: 100),
                                        scaleFactor: 1.5,
                                        onPressed: () => NavigatorUtil.navigate(this.context, EmployeeProfilePage(_model, employee.id, name, surname, employee.gender, nationality)),
                                        child: AvatarsUtil.buildAvatar(gender, 50, 16, name.substring(0, 1), surname.substring(0, 1)),
                                      ),
                                    ),
                                  ),
                                  title: text17BlackBold(name + ' ' + surname + ' ' + LanguageUtil.findFlagByNationality(nationality)),
                                  subtitle: Column(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          text17BlackBold(getTranslated(this.context, 'accord') + ': '),
                                          text16Black(employee.totalMoneyForPieceworkForEmployee.toString() + ' PLN'),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          text17BlackBold(getTranslated(this.context, 'time') + ': '),
                                          text16Black(employee.totalMoneyForTimeForEmployee.toString() + ' PLN' + ' (' + employee.totalTime + ')'),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          text17BlackBold(getTranslated(this.context, 'sum') + ': '),
                                          text16Black(employee.totalMoneyEarned.toString() + ' PLN'),
                                        ],
                                      ),
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
    );
  }
}
