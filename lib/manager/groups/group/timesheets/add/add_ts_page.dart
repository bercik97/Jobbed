import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:jobbed/api/employee/dto/employee_basic_dto.dart';
import 'package:jobbed/api/employee/service/employee_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/timesheet/service/timesheet_service.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/collection_util.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/hint.dart';

import '../../../../../internationalization/localization/localization_constants.dart';
import '../../../../../shared/libraries/colors.dart';
import '../../../../../shared/util/language_util.dart';
import '../../../../../shared/util/month_util.dart';
import '../../../../../shared/util/toast_util.dart';
import '../../../../../shared/widget/icons.dart';
import '../../../../../shared/widget/texts.dart';
import '../../../../shared/group_model.dart';
import '../../../../shared/manager_app_bar.dart';
import '../ts_page.dart';

class AddTsPage extends StatefulWidget {
  final GroupModel _model;
  final int _year;
  final int _month;

  AddTsPage(this._model, this._year, this._month);

  @override
  _AddTsPageState createState() => _AddTsPageState();
}

class _AddTsPageState extends State<AddTsPage> {
  GroupModel _model;
  User _user;

  int _year;
  int _month;

  EmployeeService _employeeService;
  TimesheetService _timesheetService;

  List<EmployeeBasicDto> _employees = new List();
  List<EmployeeBasicDto> _filteredEmployees = new List();
  bool _loading = false;
  bool _isChecked = false;
  bool _isAddBtnTapped = false;
  List<bool> _checked = new List();
  LinkedHashSet<int> _selectedIds = new LinkedHashSet();

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._year = widget._year;
    this._month = widget._month;
    this._employeeService = ServiceInitializer.initialize(context, _user.authHeader, EmployeeService);
    this._timesheetService = ServiceInitializer.initialize(context, _user.authHeader, TimesheetService);
    super.initState();
    _loading = true;
    _employeeService.findAllByGroupIdAndTsNotInYearAndMonth(_model.groupId, _year, _month).then((res) {
      setState(() {
        _employees = res;
        _employees.forEach((e) => _checked.add(false));
        _filteredEmployees = _employees;
        _loading = false;
      });
    }).catchError((onError) => DialogUtil.showFailureDialogWithWillPopScope(context, getTranslated(context, 'allEmployeesHaveTsForChosenYearAndMonth'), TsPage(_model)));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: managerAppBar(context, _user, getTranslated(context, 'addNewTimesheet'), () => Navigator.pop(context)),
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
                    text20Black(getTranslated(context, 'addNewTsForSelectedEmployeesForChosenDate')),
                    SizedBox(height: 5),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: text20OrangeBold(_year.toString() + ' ' + MonthUtil.findMonthNameByMonthNumber(this.context, _month)),
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
                  onPressed: () => Navigator.pop(context),
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
                  onPressed: () => _isAddBtnTapped ? null : _createTsForSelectedEmployees(),
                ),
              ],
            ),
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, TsPage(_model)),
    );
  }

  void _createTsForSelectedEmployees() {
    setState(() => _isAddBtnTapped = true);
    if (_selectedIds.isEmpty) {
      showHint(context, getTranslated(context, 'needToSelectEmployees') + ' ', getTranslated(context, 'forWhomYouWantToAddNewTs'));
      setState(() => _isAddBtnTapped = false);
      return;
    }
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _timesheetService.create(CollectionUtil.removeBracketsFromSet(_selectedIds), _year, _month).then(
      (res) {
        Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
          ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'timesheetsSuccessfullyCreated'));
          NavigatorUtil.navigateReplacement(context, TsPage(_model));
        });
      },
    ).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        setState(() => _isAddBtnTapped = false);
      });
    });
  }

  Future<Null> _refresh() {
    return _employeeService.findAllByGroupIdAndTsNotInYearAndMonth(_model.groupId, _year, _month).then((res) {
      setState(() {
        _employees = res;
        _employees.forEach((e) => _checked.add(false));
        _filteredEmployees = _employees;
        _loading = false;
      });
    }).catchError((onError) => DialogUtil.showFailureDialogWithWillPopScope(context, getTranslated(context, 'groupNoEmployees'), TsPage(_model)));
  }
}
