import 'dart:collection';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:jobbed/api/employee/dto/employee_statistics_dto.dart';
import 'package:jobbed/api/employee/service/employee_view_service.dart';
import 'package:jobbed/api/piecework/service/piecework_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:jobbed/api/timesheet/dto/timesheet_with_status_dto.dart';
import 'package:jobbed/api/work_time/service/work_time_service.dart';
import 'package:jobbed/api/workplace/dto/workplace_dto.dart';
import 'package:jobbed/api/workplace/service/workplace_service.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/groups/group/employee/employee_profile_page.dart';
import 'package:jobbed/manager/groups/group/employee/employee_ts_in_progress_page.dart';
import 'package:jobbed/manager/groups/group/piecework/manage/add_piecework_page.dart';
import 'package:jobbed/manager/groups/group/timesheets/ts_page.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/avatars_util.dart';
import 'package:jobbed/shared/util/collection_util.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/icons_legend_util.dart';
import 'package:jobbed/shared/util/language_util.dart';
import 'package:jobbed/shared/util/month_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/util/validator_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/hint.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/icons_legend_dialog.dart';
import 'package:jobbed/shared/widget/radio_button.dart';
import 'package:jobbed/shared/widget/refactored/callendarro_dialog.dart';
import 'package:jobbed/shared/widget/texts.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

import '../../../../shared/manager_app_bar.dart';

class TsInProgressPage extends StatefulWidget {
  final GroupModel _model;
  final TimesheetWithStatusDto _timeSheet;

  TsInProgressPage(this._model, this._timeSheet);

  @override
  _TsInProgressPageState createState() => _TsInProgressPageState();
}

class _TsInProgressPageState extends State<TsInProgressPage> {
  final TextEditingController _fromHoursController = new TextEditingController();
  final TextEditingController _fromMinutesController = new TextEditingController();
  final TextEditingController _toHoursController = new TextEditingController();
  final TextEditingController _toMinutesController = new TextEditingController();

  GroupModel _model;
  User _user;

  EmployeeViewService _employeeViewService;
  PieceworkService _pieceworkService;
  WorkTimeService _workTimeService;
  WorkplaceService _workplaceService;
  TimesheetWithStatusDto _timesheet;

  List<EmployeeStatisticsDto> _employees = new List();
  List<EmployeeStatisticsDto> _filteredEmployees = new List();
  bool _loading = false;
  bool _isChecked = false;
  List<bool> _checked = new List();
  Set<int> _selectedIds = new LinkedHashSet();

  List<WorkplaceDto> _workplaces = new List();
  List<int> _workplacesRadioValues = new List();
  int _chosenIndex = -1;
  bool _isChoseWorkplaceBtnDisabled = true;

  bool _isDeleteWorkTimeButtonTapped = false;
  bool _isDeletePieceworkButtonTapped = false;

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._employeeViewService = ServiceInitializer.initialize(context, _user.authHeader, EmployeeViewService);
    this._pieceworkService = ServiceInitializer.initialize(context, _user.authHeader, PieceworkService);
    this._workTimeService = ServiceInitializer.initialize(context, _user.authHeader, WorkTimeService);
    this._workplaceService = ServiceInitializer.initialize(context, _user.authHeader, WorkplaceService);
    this._timesheet = widget._timeSheet;
    super.initState();
    _loading = true;
    _employeeViewService.findAllByGroupIdAndTsYearAndMonthAndStatusForStatisticsView(_model.groupId, _timesheet.year, MonthUtil.findMonthNumberByMonthName(context, _timesheet.month), STATUS_IN_PROGRESS).then((res) {
      setState(() {
        _employees = res;
        _employees.forEach((e) => _checked.add(false));
        _filteredEmployees = _employees;
        _workplaceService.findAllByCompanyId(_user.companyId).then((res) {
          setState(() {
            _workplaces = res;
            _workplaces.forEach((element) => _workplacesRadioValues.add(-1));
            _loading = false;
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: managerAppBar(context, _model.user, getTranslated(context, 'timesheets'), () => NavigatorUtil.onWillPopNavigate(context, TsPage(_model))),
        body: RefreshIndicator(
          color: WHITE,
          backgroundColor: BLUE,
          onRefresh: _refresh,
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(top: 15, left: 15, bottom: 10),
                  child: text20OrangeBold(_timesheet.year.toString() + ' ' + MonthUtil.translateMonth(context, _timesheet.month) + ' → ' + getTranslated(context, STATUS_IN_PROGRESS)),
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
                        _filteredEmployees = _employees.where((u) => ((u.name + u.surname).toLowerCase().contains(string.toLowerCase()))).toList();
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
                          EmployeeStatisticsDto employee = _filteredEmployees[index];
                          int foundIndex = 0;
                          for (int i = 0; i < _employees.length; i++) {
                            if (_employees[i].id == employee.id) {
                              foundIndex = i;
                            }
                          }
                          String name = employee.name;
                          String surname = employee.surname;
                          String gender = employee.gender;
                          String nationality = employee.nationality;
                          return Card(
                            color: BRIGHTER_BLUE,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Ink(
                                  width: MediaQuery.of(context).size.width * 0.15,
                                  height: 75,
                                  color: BRIGHTER_BLUE,
                                  child: ListTileTheme(
                                    contentPadding: EdgeInsets.only(right: 10),
                                    child: CheckboxListTile(
                                      controlAffinity: ListTileControlAffinity.leading,
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
                                ),
                                InkWell(
                                  onTap: () {
                                    TimesheetForEmployeeDto _inProgressTs = new TimesheetForEmployeeDto(
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
                                    NavigatorUtil.navigate(this.context, EmployeeTsInProgressPage(_model, employee.id, name, surname, gender, nationality, _inProgressTs));
                                  },
                                  child: Ink(
                                    width: MediaQuery.of(context).size.width * 0.60,
                                    color: BRIGHTER_BLUE,
                                    child: Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          text17BlackBold(name + ' ' + surname + ' ' + LanguageUtil.findFlagByNationality(nationality)),
                                          Row(
                                            children: <Widget>[
                                              textBlackBold(getTranslated(this.context, 'accord') + ': '),
                                              textBlack(employee.totalMoneyForPieceworkForEmployee.toString() + ' PLN'),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              textBlackBold(getTranslated(this.context, 'time') + ': '),
                                              textBlack(employee.totalMoneyForTimeForEmployee.toString() + ' PLN' + ' (' + employee.totalTime + ')'),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              textBlackBold(getTranslated(this.context, 'sum') + ': '),
                                              textBlack(employee.totalMoneyEarned.toString() + ' PLN'),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 25, left: 25),
                                  child: Container(
                                    child: Transform.scale(
                                      scale: 1.2,
                                      child: BouncingWidget(
                                        duration: Duration(milliseconds: 100),
                                        scaleFactor: 2,
                                        onPressed: () => NavigatorUtil.navigate(this.context, EmployeeProfilePage(_model, employee.id, name, surname, gender, nationality)),
                                        child: AvatarsUtil.buildAvatar(gender, 40, 16, name.substring(0, 1), surname.substring(0, 1)),
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
                    color: BLUE,
                    child: Image(image: AssetImage('images/white-hours.png')),
                    onPressed: () {
                      if (_selectedIds.isEmpty) {
                        showHint(context, getTranslated(context, 'needToSelectRecords') + ' ', getTranslated(context, 'whichYouWantToUpdate'));
                        return;
                      }
                      if (_workplaces.isEmpty) {
                        showHint(context, getTranslated(context, 'noWorkplaces') + ' ', getTranslated(context, 'goToWorkplacesSectionAndAddSomeWorkplaces'));
                        return;
                      }
                      _showUpdateWorkTimeDialog();
                    },
                  ),
                ),
                SizedBox(width: 1),
                Expanded(
                  child: MaterialButton(
                    color: BLUE,
                    child: Row(
                      children: [
                        Image(image: AssetImage('images/white-hours.png')),
                        iconRed(Icons.close),
                      ],
                    ),
                    onPressed: () {
                      if (_selectedIds.isEmpty) {
                        showHint(context, getTranslated(context, 'needToSelectRecords') + ' ', getTranslated(context, 'whichYouWantToUpdate'));
                        return;
                      }
                      _showDeleteWorkTimeDialog();
                    },
                  ),
                ),
                SizedBox(width: 1),
                Expanded(
                  child: MaterialButton(
                    color: BLUE,
                    child: Image(image: AssetImage('images/white-piecework.png')),
                    onPressed: () {
                      if (_selectedIds.isNotEmpty) {
                        _showUpdatePiecework();
                      } else {
                        showHint(context, getTranslated(context, 'needToSelectRecords') + ' ', getTranslated(context, 'whichYouWantToUpdate'));
                      }
                    },
                  ),
                ),
                SizedBox(width: 1),
                Expanded(
                  child: MaterialButton(
                    color: BLUE,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(image: AssetImage('images/white-piecework.png')),
                        iconRed(Icons.close),
                      ],
                    ),
                    onPressed: () {
                      if (_selectedIds.isNotEmpty) {
                        _showDeletePiecework();
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
            IconsLegendUtil.buildIconRow(AvatarsUtil.buildAvatar('male', 30, 14, 'A', 'B'), getTranslated(context, 'employeeProfile')),
            IconsLegendUtil.buildImageRow('images/hours.png', getTranslated(context, 'manualSettingOfWorkingTimes')),
            IconsLegendUtil.buildImageWithIconRow('images/hours.png', iconRed(Icons.close), getTranslated(context, 'deletingWork')),
            IconsLegendUtil.buildImageRow('images/piecework.png', getTranslated(context, 'settingPiecework')),
            IconsLegendUtil.buildImageWithIconRow('images/piecework.png', iconRed(Icons.close), getTranslated(context, 'deletingPiecework')),
          ],
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, TsPage(_model)),
    );
  }

  void _showUpdateWorkTimeDialog() async {
    callendarroDialog(context, 'Naciśnij na wybrany dzień aby zaznaczyć').then((dates) {
      if (dates == null) {
        return;
      }
      showGeneralDialog(
        context: context,
        barrierColor: WHITE.withOpacity(0.95),
        barrierDismissible: false,
        barrierLabel: 'workTime',
        transitionDuration: Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) {
          return SizedBox.expand(
            child: Scaffold(
              backgroundColor: Colors.black12,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(top: 50), child: text20BlackBold(getTranslated(context, 'workTimeUpperCase'))),
                    SizedBox(height: 2.5),
                    text16Black(getTranslated(context, 'setWorkTimeForSelectedEmployees')),
                    SizedBox(height: 20),
                    text17BlackBold(getTranslated(context, 'startWorkTimeFrom')),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                textBlack(getTranslated(context, 'hours')),
                                SizedBox(height: 2.5),
                                NumberInputWithIncrementDecrement(
                                  controller: _fromHoursController,
                                  min: 0,
                                  max: 23,
                                  onIncrement: (value) {
                                    if (value > 23) {
                                      setState(() => value = 23);
                                    }
                                  },
                                  onSubmitted: (value) {
                                    if (value >= 23) {
                                      setState(() => _fromHoursController.text = 23.toString());
                                    }
                                  },
                                  style: TextStyle(color: BLUE),
                                  widgetContainerDecoration: BoxDecoration(border: Border.all(color: BRIGHTER_BLUE)),
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
                                textBlack(getTranslated(context, 'minutes')),
                                SizedBox(height: 2.5),
                                NumberInputWithIncrementDecrement(
                                  controller: _fromMinutesController,
                                  min: 0,
                                  max: 59,
                                  onIncrement: (value) {
                                    if (value > 59) {
                                      setState(() => value = 59);
                                    }
                                  },
                                  onSubmitted: (value) {
                                    if (value >= 59) {
                                      setState(() => _fromMinutesController.text = 59.toString());
                                    }
                                  },
                                  style: TextStyle(color: BLUE),
                                  widgetContainerDecoration: BoxDecoration(border: Border.all(color: BRIGHTER_BLUE)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    text17BlackBold(getTranslated(context, 'finishWorkTimeTo')),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                textBlack(getTranslated(context, 'hours')),
                                SizedBox(height: 2.5),
                                NumberInputWithIncrementDecrement(
                                  controller: _toHoursController,
                                  min: 0,
                                  max: 23,
                                  onIncrement: (value) {
                                    if (value > 23) {
                                      setState(() => value = 23);
                                    }
                                  },
                                  onSubmitted: (value) {
                                    if (value >= 23) {
                                      setState(() => _toHoursController.text = 23.toString());
                                    }
                                  },
                                  style: TextStyle(color: BLUE),
                                  widgetContainerDecoration: BoxDecoration(border: Border.all(color: BRIGHTER_BLUE)),
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
                                textBlack(getTranslated(context, 'minutes')),
                                SizedBox(height: 2.5),
                                NumberInputWithIncrementDecrement(
                                  controller: _toMinutesController,
                                  min: 0,
                                  max: 59,
                                  onIncrement: (value) {
                                    if (value > 59) {
                                      setState(() => value = 59);
                                    }
                                  },
                                  onSubmitted: (value) {
                                    if (value >= 59) {
                                      setState(() => _toMinutesController.text = 59.toString());
                                    }
                                  },
                                  style: TextStyle(color: BLUE),
                                  widgetContainerDecoration: BoxDecoration(border: Border.all(color: BRIGHTER_BLUE)),
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
                          color: BLUE,
                          onPressed: () {
                            int fromHours;
                            int fromMinutes;
                            int toHours;
                            int toMinutes;
                            try {
                              fromHours = int.parse(_fromHoursController.text);
                              fromMinutes = int.parse(_fromMinutesController.text);
                              toHours = int.parse(_toHoursController.text);
                              toMinutes = int.parse(_toMinutesController.text);
                            } catch (FormatException) {
                              ToastUtil.showErrorToast(this.context, getTranslated(context, 'givenValueIsNotANumber'));
                              return;
                            }
                            String validationMsg = ValidatorUtil.validateSettingManuallyWorkTimes(fromHours, fromMinutes, toHours, toMinutes, context);
                            if (validationMsg != null) {
                              ToastUtil.showErrorToast(context, validationMsg);
                              return;
                            }
                            String startTime = fromHours.toString() + ':' + fromMinutes.toString() + ':' + '00';
                            String endTime = toHours.toString() + ':' + toMinutes.toString() + ':' + '00';
                            _showChooseWorkplaceDialog(getTranslated(this.context, 'chooseWorkplace'), () => _handleSaveWorkTimesManually(dates, startTime, endTime));
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
    });
  }

  void _showChooseWorkplaceDialog(String title, Function() fun) {
    showGeneralDialog(
      context: context,
      barrierColor: WHITE.withOpacity(0.95),
      barrierDismissible: false,
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SafeArea(
          child: SizedBox.expand(
            child: StatefulBuilder(builder: (context, setState) {
              return Scaffold(
                backgroundColor: Colors.black12,
                body: Center(
                  child: Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 50, bottom: 10),
                          child: Column(
                            children: [
                              textCenter20BlueBold(title),
                            ],
                          ),
                        ),
                        SizedBox(height: 7.5),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    for (int i = 0; i < _workplaces.length; i++)
                                      RadioButton.buildRadioBtn(
                                        color: BLUE,
                                        title: _workplaces[i].name,
                                        value: 0,
                                        groupValue: _workplacesRadioValues[i],
                                        onChanged: (newValue) => setState(
                                          () {
                                            if (_chosenIndex != -1) {
                                              _workplacesRadioValues[_chosenIndex] = -1;
                                            }
                                            _workplacesRadioValues[i] = newValue;
                                            _chosenIndex = i;
                                            _isChoseWorkplaceBtnDisabled = false;
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
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
                                onPressed: () {
                                  if (_chosenIndex != -1) {
                                    _workplacesRadioValues[_chosenIndex] = -1;
                                  }
                                  _chosenIndex = -1;
                                  _isChoseWorkplaceBtnDisabled = true;
                                  Navigator.pop(context);
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
                                color: !_isChoseWorkplaceBtnDisabled ? BLUE : Colors.grey,
                                onPressed: () {
                                  if (_isChoseWorkplaceBtnDisabled) {
                                    return;
                                  }
                                  fun();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  void _handleSaveWorkTimesManually(List<String> dates, String startTime, String endTime) {
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _workTimeService.saveByEmployeeIdsAndDates(CollectionUtil.removeBracketsFromSet(_selectedIds), CollectionUtil.removeBracketsFromSet(dates.toSet()), _workplaces[_chosenIndex].id, startTime, endTime).then((value) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        _refresh();
        Navigator.pop(context);
        Navigator.pop(context);
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'workingTimeHasBeenSuccessfullySetForSelectedDaysAndEmployees'));
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
      });
    });
  }

  void _showDeleteWorkTimeDialog() async {
    callendarroDialog(context, 'Naciśnij na wybrany dzień aby zaznaczyć').then((dates) {
      if (dates == null) {
        return;
      }
      DialogUtil.showConfirmationDialog(
        context: this.context,
        title: getTranslated(this.context, 'confirmation'),
        content: getTranslated(this.context, 'deleteWorkConfirmation'),
        isBtnTapped: _isDeleteWorkTimeButtonTapped,
        agreeFun: () => _isDeleteWorkTimeButtonTapped ? null : _handleDeleteWorkTime(dates),
      );
    });
  }

  _handleDeleteWorkTime(List<String> dates) {
    setState(() => _isDeleteWorkTimeButtonTapped = true);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _workTimeService.deleteByEmployeeIdsAndDates(CollectionUtil.removeBracketsFromSet(_selectedIds), CollectionUtil.removeBracketsFromSet(dates.toSet())).then((value) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        _refresh();
        Navigator.of(context).pop();
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'workHasBeenSuccessfullyDeleted'));
        setState(() => _isDeleteWorkTimeButtonTapped = false);
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogUtil.showErrorDialog(this.context, getTranslated(this.context, 'somethingWentWrong'));
        setState(() => _isDeleteWorkTimeButtonTapped = false);
      });
    });
  }

  void _showUpdatePiecework() async {
    callendarroDialog(context, 'Naciśnij na wybrany dzień aby zaznaczyć').then((dates) {
      if (dates == null) {
        return;
      }
      NavigatorUtil.navigate(context, AddPieceworkPage(_model, dates, _selectedIds, null));
    });
  }

  void _showDeletePiecework() async {
    callendarroDialog(context, 'Naciśnij na wybrany dzień aby zaznaczyć').then((dates) {
      if (dates == null) {
        return;
      }
      DialogUtil.showConfirmationDialog(
        context: context,
        title: getTranslated(context, 'confirmation'),
        content: getTranslated(context, 'deletingPieceworkConfirmation'),
        isBtnTapped: _isDeletePieceworkButtonTapped,
        agreeFun: () => _isDeletePieceworkButtonTapped ? null : _handleDeletePiecework(dates),
      );
    });
  }

  void _handleDeletePiecework(List<String> dates) {
    setState(() => _isDeletePieceworkButtonTapped = true);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _pieceworkService.deleteByEmployeeIdsAndDates(CollectionUtil.removeBracketsFromSet(dates.toSet()), CollectionUtil.removeBracketsFromSet(_selectedIds)).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        _refresh();
        Navigator.of(context).pop();
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'pieceworkForSelectedDaysAndEmployeesDeleted'));
        setState(() => _isDeletePieceworkButtonTapped = false);
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        setState(() => _isDeletePieceworkButtonTapped = false);
      });
    });
  }

  Future<Null> _refresh() {
    return _employeeViewService.findAllByGroupIdAndTsYearAndMonthAndStatusForStatisticsView(_model.groupId, _timesheet.year, MonthUtil.findMonthNumberByMonthName(context, _timesheet.month), STATUS_IN_PROGRESS).then((res) {
      setState(() {
        _employees = res;
        _employees.forEach((e) => _checked.add(false));
        _filteredEmployees = _employees;
        _loading = false;
      });
    });
  }
}
