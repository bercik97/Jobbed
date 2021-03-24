import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:jobbed/api/employee/dto/employee_basic_dto.dart';
import 'package:jobbed/api/employee/service/employee_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/timesheet/service/timesheet_service.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/hint.dart';

import '../../../../../internationalization/localization/localization_constants.dart';
import '../../../../../shared/libraries/colors.dart';
import '../../../../../shared/libraries/constants.dart';
import '../../../../../shared/util/language_util.dart';
import '../../../../../shared/util/month_util.dart';
import '../../../../../shared/util/toast_util.dart';
import '../../../../../shared/widget/icons.dart';
import '../../../../../shared/widget/texts.dart';
import '../../../../shared/group_model.dart';
import '../../../../shared/manager_app_bar.dart';
import '../ts_page.dart';

class ChangeTsStatusPage extends StatefulWidget {
  final GroupModel _model;
  final int _year;
  final String _month;
  final String _status;

  ChangeTsStatusPage(this._model, this._year, this._month, this._status);

  @override
  _ChangeTsStatusPageState createState() => _ChangeTsStatusPageState();
}

class _ChangeTsStatusPageState extends State<ChangeTsStatusPage> {
  GroupModel _model;
  User _user;

  int _year;
  int _month;
  String _status;

  EmployeeService _employeeService;
  TimesheetService _timesheetService;

  List<EmployeeBasicDto> _employees = new List();
  List<EmployeeBasicDto> _filteredEmployees = new List();
  bool _loading = false;
  bool _isChecked = false;
  bool _isChangeBtnTapped = false;
  List<bool> _checked = new List();
  LinkedHashSet<int> _selectedIds = new LinkedHashSet();

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._year = widget._year;
    this._month = MonthUtil.findMonthNumberByMonthName(context, widget._month);
    this._status = widget._status;
    this._employeeService = ServiceInitializer.initialize(context, _user.authHeader, EmployeeService);
    this._timesheetService = ServiceInitializer.initialize(context, _user.authHeader, TimesheetService);
    super.initState();
    _loading = true;
    _employeeService.findAllByGroupIdAndTsInYearAndMonthAndStatus(_model.groupId, _year, _month, _status == STATUS_COMPLETED ? STATUS_IN_PROGRESS : STATUS_COMPLETED).then((res) {
      setState(() {
        _employees = res;
        _employees.forEach((e) => _checked.add(false));
        _filteredEmployees = _employees;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WHITE,
      appBar: managerAppBar(context, _model.user, getTranslated(context, 'changeTimesheetStatus'), () => Navigator.pop(context)),
      body: RefreshIndicator(
        color: WHITE,
        backgroundColor: BLUE,
        onRefresh: _refresh,
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 15, left: 15, bottom: 10),
              child: Column(
                children: [
                  text20Black(getTranslated(context, 'updateSelectedTsStatusForChosenEmployees')),
                  SizedBox(height: 5),
                  _status == STATUS_COMPLETED
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              text20OrangeBold(_year.toString() + ' ' + MonthUtil.findMonthNameByMonthNumber(this.context, _month) + ' ' + '→ '),
                              text20GreenBold(getTranslated(context, _status).toUpperCase()),
                            ],
                          ),
                        )
                      : Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              text20GreenBold(_year.toString() + ' ' + MonthUtil.findMonthNameByMonthNumber(this.context, _month) + ' ' + '→ '),
                              text20OrangeBold(getTranslated(context, _status).toUpperCase()),
                            ],
                          ),
                        ),
                ],
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
                  labelText: getTranslated(this.context, 'search'),
                  prefixIcon: iconBlack(Icons.search),
                  labelStyle: TextStyle(color: BLACK),
                ),
                onChanged: (string) {
                  setState(
                    () {
                      _filteredEmployees = _employees.where((e) => ((e.name + e.surname).toLowerCase().contains(string.toLowerCase()))).toList();
                    },
                  );
                },
              ),
            ),
            ListTileTheme(
              contentPadding: EdgeInsets.only(left: 3),
              child: CheckboxListTile(
                title: textBlack(getTranslated(this.context, 'selectUnselectAll')),
                value: _isChecked,
                activeColor: BLUE,
                checkColor: WHITE,
                onChanged: (bool value) {
                  setState(() {
                    _isChecked = value;
                    List<bool> l = new List();
                    _checked.forEach((b) => l.add(value));
                    _checked = l;
                    if (value) {
                      _selectedIds.addAll(_filteredEmployees.map((e) => e.id));
                    } else
                      _selectedIds.clear();
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            _loading
                ? circularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: _filteredEmployees.length,
                      itemBuilder: (BuildContext context, int index) {
                        EmployeeBasicDto employee = _filteredEmployees[index];
                        int foundIndex = 0;
                        for (int i = 0; i < _employees.length; i++) {
                          if (_employees[i].id == employee.id) {
                            foundIndex = i;
                          }
                        }
                        String info = employee.name + ' ' + employee.surname;
                        String nationality = employee.nationality;
                        return Card(
                          color: WHITE,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                color: BRIGHTER_BLUE,
                                child: ListTileTheme(
                                  contentPadding: EdgeInsets.only(right: 10),
                                  child: CheckboxListTile(
                                    controlAffinity: ListTileControlAffinity.leading,
                                    title: text20BlackBold(info + ' ' + LanguageUtil.findFlagByNationality(nationality)),
                                    activeColor: BLUE,
                                    checkColor: WHITE,
                                    value: _checked[foundIndex],
                                    onChanged: (bool value) {
                                      setState(() {
                                        _checked[foundIndex] = value;
                                        if (value) {
                                          _selectedIds.add(_employees[foundIndex].id);
                                        } else {
                                          _selectedIds.remove(_employees[foundIndex].id);
                                        }
                                        int selectedIdsLength = _selectedIds.length;
                                        if (selectedIdsLength == _employees.length) {
                                          _isChecked = true;
                                        } else if (selectedIdsLength == 0) {
                                          _isChecked = false;
                                        }
                                      });
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              MaterialButton(
                elevation: 0,
                height: 50,
                minWidth: 40,
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[iconWhite(Icons.close)],
                ),
                color: Colors.red,
                onPressed: () => {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => TsPage(_model)), (e) => false),
                },
              ),
              SizedBox(width: 25),
              MaterialButton(
                elevation: 0,
                height: 50,
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[iconWhite(Icons.check)],
                ),
                color: BLUE,
                onPressed: () {
                  if (_isChangeBtnTapped) {
                    return;
                  }
                  if (_status == STATUS_IN_PROGRESS) {
                    _updateTsStatusForSelectedEmployees(1, STATUS_COMPLETED);
                  } else {
                    _updateTsStatusForSelectedEmployees(2, STATUS_IN_PROGRESS);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateTsStatusForSelectedEmployees(int newStatusId, String status) {
    setState(() => _isChangeBtnTapped = true);
    if (_selectedIds.isEmpty) {
      showHint(context, getTranslated(context, 'needToSelectEmployees') + ' ', getTranslated(context, 'forWhomYouWantToUpdateTsStatus'));
      setState(() => _isChangeBtnTapped = false);
      return;
    }
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _timesheetService.updateTsStatusByGroupIdAndYearAndMonthAndStatusAndEmployeesIdIn(_selectedIds.map((el) => el.toString()).toList(), newStatusId, _year, _month, status, _model.groupId).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'timesheetStatusSuccessfullyUpdated'));
        NavigatorUtil.navigateReplacement(context, TsPage(_model));
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showErrorToast(context, 'somethingWentWrong');
        setState(() => _isChangeBtnTapped = false);
      });
    });
  }

  Future<Null> _refresh() {
    return _employeeService.findAllByGroupIdAndTsInYearAndMonthAndStatus(_model.groupId, _year, _month, _status == STATUS_COMPLETED ? STATUS_IN_PROGRESS : STATUS_COMPLETED).then((res) {
      setState(() {
        _employees = res;
        _employees.forEach((e) => _checked.add(false));
        _filteredEmployees = _employees;
        _loading = false;
      });
    });
  }
}
