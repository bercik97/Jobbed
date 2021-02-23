import 'dart:collection';
import 'dart:convert';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:date_util/date_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:give_job/api/employee/dto/employee_statistics_dto.dart';
import 'package:give_job/api/employee/service/employee_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:give_job/api/timesheet/dto/timesheet_with_status_dto.dart';
import 'package:give_job/api/workday/service/workday_service.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/employee/employee_profile_page.dart';
import 'package:give_job/manager/groups/group/employee/employee_ts_in_progress_page.dart';
import 'package:give_job/manager/groups/group/piecework/add_piecework_for_selected_employees_page.dart';
import 'package:give_job/manager/groups/group/timesheets/ts_page.dart';
import 'package:give_job/manager/shared/group_model.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/dialog_service.dart';
import 'package:give_job/shared/service/toast_service.dart';
import 'package:give_job/shared/service/validator_service.dart';
import 'package:give_job/shared/util/avatars_util.dart';
import 'package:give_job/shared/util/icons_legend_util.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/util/month_util.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/hint.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/icons_legend_dialog.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:intl/intl.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

import '../../../../../shared/widget/loader.dart';
import '../../../../shared/manager_app_bar.dart';

class TsInProgressPage extends StatefulWidget {
  final GroupModel _model;
  final TimesheetWithStatusDto _timeSheet;

  TsInProgressPage(this._model, this._timeSheet);

  @override
  _TsInProgressPageState createState() => _TsInProgressPageState();
}

class _TsInProgressPageState extends State<TsInProgressPage> {
  final TextEditingController _hoursController = new TextEditingController();
  final TextEditingController _minutesController = new TextEditingController();
  final TextEditingController _noteController = new TextEditingController();

  GroupModel _model;
  User _user;

  EmployeeService _employeeService;
  WorkdayService _workdayService;
  TimesheetWithStatusDto _timesheet;

  List<EmployeeStatisticsDto> _employees = new List();
  List<EmployeeStatisticsDto> _filteredEmployees = new List();
  bool _loading = false;
  bool _isChecked = false;
  List<bool> _checked = new List();
  LinkedHashSet<int> _selectedIds = new LinkedHashSet();

  bool _isDeletePieceworkButtonTapped = false;

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._employeeService = ServiceInitializer.initialize(context, _user.authHeader, EmployeeService);
    this._workdayService = ServiceInitializer.initialize(context, _user.authHeader, WorkdayService);
    this._timesheet = widget._timeSheet;
    super.initState();
    _loading = true;
    _employeeService
        .findAllByGroupIdAndTsYearAndMonthAndStatusForStatisticsView(
      _model.groupId,
      _timesheet.year,
      MonthUtil.findMonthNumberByMonthName(context, _timesheet.month),
      STATUS_IN_PROGRESS,
    )
        .then((res) {
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
    if (_loading) {
      return loader(managerAppBar(context, _model.user, getTranslated(context, 'loading'), () => Navigator.pop(context)));
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
            utf8.decode(_model.groupName != null ? _model.groupName.runes.toList() : '-'),
            () => NavigatorUtil.navigate(context, TsPage(_model)),
          ),
          body: RefreshIndicator(
            color: DARK,
            backgroundColor: WHITE,
            onRefresh: _refresh,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 15, left: 15, bottom: 10),
                  child: text20OrangeBold(_timesheet.year.toString() + ' ' + MonthUtil.translateMonth(context, _timesheet.month) + ' → ' + getTranslated(context, STATUS_IN_PROGRESS)),
                ),
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
                      labelText: getTranslated(this.context, 'search'),
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
                ListTileTheme(
                  contentPadding: EdgeInsets.only(left: 3),
                  child: CheckboxListTile(
                    title: textWhite(getTranslated(this.context, 'selectUnselectAll')),
                    value: _isChecked,
                    activeColor: GREEN,
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
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredEmployees.length,
                    itemBuilder: (BuildContext context, int index) {
                      EmployeeStatisticsDto employee = _filteredEmployees[index];
                      int foundIndex = 0;
                      for (int i = 0; i < _employees.length; i++) {
                        if (_employees[i].id == employee.id) {
                          foundIndex = i;
                        }
                      }
                      String info = employee.info;
                      String nationality = employee.nationality;
                      String avatarPath = AvatarsUtil.getAvatarPathByLetter(employee.gender, info.substring(0, 1));
                      return Card(
                        color: DARK,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Ink(
                              width: MediaQuery.of(context).size.width * 0.15,
                              height: 90,
                              color: BRIGHTER_DARK,
                              child: ListTileTheme(
                                contentPadding: EdgeInsets.only(right: 10),
                                child: CheckboxListTile(
                                  controlAffinity: ListTileControlAffinity.leading,
                                  activeColor: GREEN,
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
                            ),
                            SizedBox(width: 10),
                            InkWell(
                              onTap: () {
                                TimesheetForEmployeeDto _inProgressTs = new TimesheetForEmployeeDto(
                                  id: employee.timesheetId,
                                  year: _timesheet.year,
                                  month: _timesheet.month,
                                  status: _timesheet.status,
                                  totalHours: _filteredEmployees[index].totalHours,
                                  totalMoneyForHoursForEmployee: _filteredEmployees[index].totalMoneyForHoursForEmployee,
                                  totalMoneyForPieceworkForEmployee: _filteredEmployees[index].totalMoneyForPieceworkForEmployee,
                                  totalMoneyEarned: _filteredEmployees[index].totalMoneyEarned,
                                  employeeBasicDto: null,
                                );
                                NavigatorUtil.navigate(this.context, EmployeeTsInProgressPage(_model, info, employee.id, nationality, _inProgressTs, avatarPath));
                              },
                              child: Ink(
                                width: MediaQuery.of(context).size.width * 0.60,
                                color: BRIGHTER_DARK,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      text17WhiteBold(utf8.decode(info.runes.toList()) + ' ' + LanguageUtil.findFlagByNationality(nationality)),
                                      Row(
                                        children: <Widget>[
                                          textWhite(getTranslated(this.context, 'hours') + ': '),
                                          textGreenBold(employee.totalMoneyForHoursForEmployee.toString() + ' PLN' + ' (' + employee.totalHours + ' h)'),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          textWhite(getTranslated(this.context, 'accord') + ': '),
                                          textGreenBold(employee.totalMoneyForPieceworkForEmployee.toString() + ' PLN'),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          textWhite(getTranslated(this.context, 'sum') + ': '),
                                          textGreenBold(employee.totalMoneyEarned.toString() + ' PLN'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 15),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Transform.scale(
                                  scale: 1.2,
                                  child: BouncingWidget(
                                    duration: Duration(milliseconds: 100),
                                    scaleFactor: 2,
                                    onPressed: () => NavigatorUtil.navigate(this.context, EmployeeProfilePage(_model, nationality, employee.id, info, avatarPath)),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image(image: AssetImage(avatarPath), height: 40),
                                      ],
                                    ),
                                  ),
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
            child: Container(
              height: 40,
              child: Row(
                children: <Widget>[
                  SizedBox(width: 1),
                  Expanded(
                    child: MaterialButton(
                      color: GREEN,
                      child: Image(image: AssetImage('images/dark-hours-icon.png')),
                      onPressed: () {
                        if (_selectedIds.isNotEmpty) {
                          _hoursController.clear();
                          _minutesController.clear();
                          _showUpdateHoursDialog(_selectedIds);
                        } else {
                          showHint(context, getTranslated(context, 'needToSelectRecords') + ' ', getTranslated(context, 'whichYouWantToUpdate'));
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 1),
                  Expanded(
                    child: MaterialButton(
                      color: GREEN,
                      child: Image(image: AssetImage('images/dark-piecework-icon.png')),
                      onPressed: () {
                        if (_selectedIds.isNotEmpty) {
                          _showUpdatePiecework(_selectedIds);
                        } else {
                          showHint(context, getTranslated(context, 'needToSelectRecords') + ' ', getTranslated(context, 'whichYouWantToUpdate'));
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 1),
                  Expanded(
                    child: MaterialButton(
                      color: GREEN,
                      child: Row(
                        children: [
                          Image(image: AssetImage('images/dark-piecework-icon.png')),
                          iconRed(Icons.close),
                        ],
                      ),
                      onPressed: () {
                        if (_selectedIds.isNotEmpty) {
                          _showDeletePiecework(_selectedIds);
                        } else {
                          showHint(context, getTranslated(context, 'needToSelectRecords') + ' ', getTranslated(context, 'whichYouWantToUpdate'));
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 1),
                  Expanded(
                    child: MaterialButton(
                      color: GREEN,
                      child: Image(image: AssetImage('images/dark-note-icon.png')),
                      onPressed: () {
                        if (_selectedIds.isNotEmpty) {
                          _noteController.clear();
                          _showUpdateNoteDialog(_selectedIds);
                        } else {
                          showHint(context, getTranslated(context, 'needToSelectRecords') + ' ', getTranslated(context, 'whichYouWantToUpdate'));
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 1),
                ],
              ),
            ),
          ),
          floatingActionButton: iconsLegendDialog(
            context,
            getTranslated(context, 'iconsLegend'),
            [
              IconsLegendUtil.buildImageRow('images/letters/male/unknown_letter.png', getTranslated(context, 'employeeProfile')),
              IconsLegendUtil.buildImageRow('images/green-hours-icon.png', getTranslated(context, 'settingHours')),
              IconsLegendUtil.buildImageRow('images/green-piecework-icon.png', getTranslated(context, 'settingPiecework')),
              IconsLegendUtil.buildImageWithIconRow('images/green-piecework-icon.png', iconRed(Icons.close), getTranslated(context, 'deletingPiecework')),
              IconsLegendUtil.buildImageRow('images/green-note-icon.png', getTranslated(context, 'settingNote')),
            ],
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, TsPage(_model)),
    );
  }

  void _showUpdateHoursDialog(LinkedHashSet<int> selectedIds) async {
    int year = _timesheet.year;
    int monthNum = MonthUtil.findMonthNumberByMonthName(context, _timesheet.month);
    int days = DateUtil().daysInMonth(monthNum, year);
    final List<DateTime> picked = await DateRagePicker.showDatePicker(
      context: context,
      initialFirstDate: new DateTime(year, monthNum, 1),
      initialLastDate: new DateTime(year, monthNum, days),
      firstDate: new DateTime(year, monthNum, 1),
      lastDate: new DateTime(year, monthNum, days),
    );
    if (picked != null && picked.length == 1) {
      picked.add(picked[0]);
    }
    if (picked != null && picked.length == 2) {
      String dateFrom = DateFormat('yyyy-MM-dd').format(picked[0]);
      String dateTo = DateFormat('yyyy-MM-dd').format(picked[1]);
      showGeneralDialog(
        context: context,
        barrierColor: DARK.withOpacity(0.95),
        barrierDismissible: false,
        barrierLabel: 'Hours',
        transitionDuration: Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) {
          return SizedBox.expand(
            child: Scaffold(
              backgroundColor: Colors.black12,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(top: 50), child: text20GreenBold(getTranslated(context, 'hoursUpperCase'))),
                    SizedBox(height: 2.5),
                    textGreen(getTranslated(context, 'setHoursForSelectedEmployee')),
                    SizedBox(height: 2.5),
                    textGreenBold('[' + dateFrom + ' - ' + dateTo + ']'),
                    SizedBox(height: 2.5),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                textWhite(getTranslated(context, 'hoursNumber')),
                                SizedBox(height: 2.5),
                                NumberInputWithIncrementDecrement(
                                  controller: _hoursController,
                                  min: 0,
                                  max: 24,
                                  onIncrement: (value) {
                                    if (value > 24) {
                                      setState(() => value = 24);
                                    }
                                  },
                                  onSubmitted: (value) {
                                    if (value >= 24) {
                                      setState(() => _hoursController.text = 24.toString());
                                    }
                                  },
                                  style: TextStyle(color: GREEN),
                                  widgetContainerDecoration: BoxDecoration(border: Border.all(color: BRIGHTER_DARK)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                textWhite(getTranslated(context, 'minutesNumber')),
                                SizedBox(height: 2.5),
                                NumberInputWithIncrementDecrement(
                                  controller: _minutesController,
                                  min: 0,
                                  max: 59,
                                  onIncrement: (value) {
                                    if (value > 59) {
                                      setState(() => value = 59);
                                    }
                                  },
                                  onSubmitted: (value) {
                                    if (value >= 59) {
                                      setState(() => _minutesController.text = 59.toString());
                                    }
                                  },
                                  style: TextStyle(color: GREEN),
                                  widgetContainerDecoration: BoxDecoration(border: Border.all(color: BRIGHTER_DARK)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
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
                          color: GREEN,
                          onPressed: () {
                            double hours;
                            double minutes;
                            try {
                              hours = double.parse(_hoursController.text);
                              minutes = double.parse(_minutesController.text) * 0.01;
                            } catch (FormatException) {
                              ToastService.showErrorToast(getTranslated(context, 'givenValueIsNotANumber'));
                              return;
                            }
                            String invalidMessage = ValidatorService.validateUpdatingHoursWithMinutes(hours, minutes, context);
                            if (invalidMessage != null) {
                              ToastService.showErrorToast(invalidMessage);
                              return;
                            }
                            FocusScope.of(context).unfocus();
                            hours += minutes;
                            showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                            _workdayService
                                .updateHoursByEmployeeIds(
                              hours,
                              dateFrom,
                              dateTo,
                              _selectedIds.map((el) => el.toString()).toList(),
                              year,
                              monthNum,
                              STATUS_IN_PROGRESS,
                            )
                                .then((res) {
                              Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                Navigator.of(context).pop();
                                ToastService.showSuccessToast(getTranslated(context, 'hoursUpdatedSuccessfully'));
                                _refresh();
                              });
                            }).catchError((onError) {
                              Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                ToastService.showErrorToast('somethingWentWrong');
                              });
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }

  void _showUpdatePiecework(LinkedHashSet<int> selectedIds) async {
    int year = _timesheet.year;
    int monthNum = MonthUtil.findMonthNumberByMonthName(context, _timesheet.month);
    int days = DateUtil().daysInMonth(monthNum, year);
    final List<DateTime> picked = await DateRagePicker.showDatePicker(
      context: context,
      initialFirstDate: new DateTime(year, monthNum, 1),
      initialLastDate: new DateTime(year, monthNum, days),
      firstDate: new DateTime(year, monthNum, 1),
      lastDate: new DateTime(year, monthNum, days),
    );
    if (picked != null && picked.length == 1) {
      picked.add(picked[0]);
    }
    if (picked != null && picked.length == 2) {
      String dateFrom = DateFormat('yyyy-MM-dd').format(picked[0]);
      String dateTo = DateFormat('yyyy-MM-dd').format(picked[1]);
      NavigatorUtil.navigate(
        context,
        AddPieceworkForSelectedEmployeesPage(
          _model,
          _timesheet,
          dateFrom,
          dateTo,
          _selectedIds.map((el) => el.toString()).toList(),
          year,
          monthNum,
          STATUS_IN_PROGRESS,
        ),
      );
    }
  }

  void _showDeletePiecework(LinkedHashSet<int> selectedIds) async {
    int year = _timesheet.year;
    int monthNum = MonthUtil.findMonthNumberByMonthName(context, _timesheet.month);
    int days = DateUtil().daysInMonth(monthNum, year);
    final List<DateTime> picked = await DateRagePicker.showDatePicker(
      context: context,
      initialFirstDate: new DateTime(year, monthNum, 1),
      initialLastDate: new DateTime(year, monthNum, days),
      firstDate: new DateTime(year, monthNum, 1),
      lastDate: new DateTime(year, monthNum, days),
    );
    if (picked != null && picked.length == 1) {
      picked.add(picked[0]);
    }
    String dateFrom;
    String dateTo;
    if (picked != null && picked.length == 2) {
      dateFrom = DateFormat('yyyy-MM-dd').format(picked[0]);
      dateTo = DateFormat('yyyy-MM-dd').format(picked[1]);
    }
    DialogService.showConfirmationDialog(
      context: context,
      title: getTranslated(context, 'confirmation'),
      content: getTranslated(context, 'deletingPieceworkConfirmation'),
      isBtnTapped: _isDeletePieceworkButtonTapped,
      fun: () => _isDeletePieceworkButtonTapped ? null : _handleDeletePiecework(dateFrom, dateTo, selectedIds.map((el) => el.toString()).toList(), year, monthNum, STATUS_IN_PROGRESS),
    );
  }

  void _handleDeletePiecework(String dateFrom, String dateTo, List<String> employeeIds, int tsYear, int tsMonth, String tsStatus) {
    setState(() => _isDeletePieceworkButtonTapped = true);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _workdayService.deletePieceworkByEmployeeIds(dateFrom, dateTo, employeeIds, tsYear, tsMonth, tsStatus).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        _refresh();
        Navigator.of(context).pop();
        ToastService.showSuccessToast(getTranslated(context, 'pieceworkForSelectedDaysAndEmployeesDeleted'));
        setState(() => _isDeletePieceworkButtonTapped = false);
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogService.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        setState(() => _isDeletePieceworkButtonTapped = false);
      });
    });
  }

  void _showUpdateNoteDialog(LinkedHashSet<int> selectedIds) async {
    int year = _timesheet.year;
    int monthNum = MonthUtil.findMonthNumberByMonthName(context, _timesheet.month);
    int days = DateUtil().daysInMonth(monthNum, year);
    final List<DateTime> picked = await DateRagePicker.showDatePicker(
      context: context,
      initialFirstDate: new DateTime(year, monthNum, 1),
      initialLastDate: new DateTime(year, monthNum, days),
      firstDate: new DateTime(year, monthNum, 1),
      lastDate: new DateTime(year, monthNum, days),
    );
    if (picked.length == 1) {
      picked.add(picked[0]);
    }
    if (picked != null && picked.length == 2) {
      String dateFrom = DateFormat('yyyy-MM-dd').format(picked[0]);
      String dateTo = DateFormat('yyyy-MM-dd').format(picked[1]);
      showGeneralDialog(
        context: context,
        barrierColor: DARK.withOpacity(0.95),
        barrierDismissible: false,
        barrierLabel: 'Note',
        transitionDuration: Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) {
          return SizedBox.expand(
            child: Scaffold(
              backgroundColor: Colors.black12,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(top: 50), child: text20GreenBold(getTranslated(context, 'note'))),
                    SizedBox(height: 2.5),
                    textGreen(getTranslated(context, 'noteForSelectedEmployees')),
                    SizedBox(height: 2.5),
                    textGreenBold('[' + dateFrom + ' - ' + dateTo + ']'),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.only(left: 25, right: 25),
                      child: TextFormField(
                        autofocus: false,
                        controller: _noteController,
                        keyboardType: TextInputType.multiline,
                        maxLength: 510,
                        maxLines: 5,
                        cursorColor: WHITE,
                        textAlignVertical: TextAlignVertical.center,
                        style: TextStyle(color: WHITE),
                        decoration: InputDecoration(
                          hintText: getTranslated(context, 'textSomeNote'),
                          hintStyle: TextStyle(color: MORE_BRIGHTER_DARK),
                          counterStyle: TextStyle(color: WHITE),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: GREEN, width: 2.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: GREEN, width: 2.5),
                          ),
                        ),
                      ),
                    ),
                    Row(
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
                          color: GREEN,
                          onPressed: () {
                            String note = _noteController.text;
                            String invalidMessage = ValidatorService.validateNote(note, context);
                            if (invalidMessage != null) {
                              ToastService.showErrorToast(invalidMessage);
                              return;
                            }
                            FocusScope.of(context).unfocus();
                            showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                            _workdayService
                                .updateNoteByEmployeeIds(
                              note,
                              dateFrom,
                              dateTo,
                              _selectedIds.map((el) => el.toString()).toList(),
                              year,
                              monthNum,
                              STATUS_IN_PROGRESS,
                            )
                                .then((res) {
                              Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                _refresh();
                                Navigator.of(context).pop();
                                ToastService.showSuccessToast(getTranslated(context, 'noteUpdatedSuccessfully'));
                              });
                            }).catchError((onError) {
                              Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                ToastService.showErrorToast('somethingWentWrong');
                              });
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }

  Future<Null> _refresh() {
    return _employeeService
        .findAllByGroupIdAndTsYearAndMonthAndStatusForStatisticsView(
      _model.groupId,
      _timesheet.year,
      MonthUtil.findMonthNumberByMonthName(context, _timesheet.month),
      STATUS_IN_PROGRESS,
    )
        .then((res) {
      setState(() {
        _employees = res;
        _employees.forEach((e) => _checked.add(false));
        _filteredEmployees = _employees;
        _loading = false;
      });
    });
  }
}
