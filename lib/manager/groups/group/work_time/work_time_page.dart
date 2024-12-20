import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:jobbed/api/employee/dto/employee_work_time_dto.dart';
import 'package:jobbed/api/employee/service/employee_view_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/work_time/dto/create_work_time_dto.dart';
import 'package:jobbed/api/work_time/service/work_time_service.dart';
import 'package:jobbed/api/workplace/dto/workplace_dto.dart';
import 'package:jobbed/api/workplace/service/workplace_service.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/groups/group/employee/employee_profile_page.dart';
import 'package:jobbed/manager/groups/group/group_page.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/manager/shared/manager_app_bar.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/collection_util.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/icons_legend_util.dart';
import 'package:jobbed/shared/util/language_util.dart';
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

class WorkTimePage extends StatefulWidget {
  final GroupModel _model;

  WorkTimePage(this._model);

  @override
  _WorkTimePageState createState() => _WorkTimePageState();
}

class _WorkTimePageState extends State<WorkTimePage> {
  final TextEditingController _fromHoursController = new TextEditingController();
  final TextEditingController _fromMinutesController = new TextEditingController();
  final TextEditingController _toHoursController = new TextEditingController();
  final TextEditingController _toMinutesController = new TextEditingController();

  EmployeeViewService _employeeViewService;
  WorkplaceService _workplaceService;
  WorkTimeService _workTimeService;

  GroupModel _model;
  User _user;

  List<EmployeeWorkTimeDto> _employees = new List();
  List<EmployeeWorkTimeDto> _filteredEmployees = new List();

  List<WorkplaceDto> _workplaces = new List();
  List<int> _workplacesRadioValues = new List();
  int _chosenIndex = -1;
  bool _isChoseWorkplaceBtnDisabled = true;
  bool _isPauseButtonTapped = false;
  bool _isDeleteWorkButtonTapped = false;

  bool _loading = false;

  bool _isChecked = false;
  List<bool> _checked = new List();
  Set<int> _selectedIds = new LinkedHashSet();
  LinkedHashSet<EmployeeWorkTimeDto> _selectedEmployees = new LinkedHashSet();

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._employeeViewService = ServiceInitializer.initialize(context, _user.authHeader, EmployeeViewService);
    this._workplaceService = ServiceInitializer.initialize(context, _user.authHeader, WorkplaceService);
    this._workTimeService = ServiceInitializer.initialize(context, _user.authHeader, WorkTimeService);
    super.initState();
    _loading = true;
    _employeeViewService.findAllByGroupIdForWorkTimeView(_model.groupId).then((res) {
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
    }).catchError((onError) {
      String errorMsg = onError.toString();
      if (errorMsg.contains("NO_EMPLOYEES_IN_GROUP_OR_THEY_DO_NOT_HAVE_TIMESHEET_FOR_CURRENT_MONTH")) {
        DialogUtil.showFailureDialogWithWillPopScope(context, getTranslated(context, 'noEmployeesInGroupOrTheyDoNotHaveTimesheetForCurrentMonth'), GroupPage(_model));
      } else {
        DialogUtil.showFailureDialogWithWillPopScope(context, getTranslated(context, 'somethingWentWrong'), GroupPage(_model));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WHITE,
      appBar: managerAppBar(context, _user, getTranslated(context, 'workTimes'), () => NavigatorUtil.navigateReplacement(context, GroupPage(_model))),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
            child: text18Black(getTranslated(context, 'workTimePageTitle')),
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
                counterStyle: TextStyle(color: WHITE),
                border: OutlineInputBorder(),
                labelText: getTranslated(context, 'search'),
                prefixIcon: iconBlack(Icons.search),
                labelStyle: TextStyle(color: BLACK),
              ),
              onChanged: (string) {
                setState(
                  () {
                    _filteredEmployees = _employees.where((u) => ((u.name + ' ' + u.surname).toLowerCase().contains(string.toLowerCase()))).toList();
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
                    _selectedEmployees.addAll(_filteredEmployees);
                  } else {
                    _selectedIds.clear();
                    _selectedEmployees.clear();
                  }
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
          _loading
              ? circularProgressIndicator()
              : _employees.isNotEmpty
                  ? Expanded(
                      child: RefreshIndicator(
                        color: WHITE,
                        backgroundColor: BLUE,
                        onRefresh: _refresh,
                        child: ListView.builder(
                          itemCount: _filteredEmployees.length,
                          itemBuilder: (BuildContext context, int index) {
                            EmployeeWorkTimeDto employee = _filteredEmployees[index];
                            int foundIndex = 0;
                            for (int i = 0; i < _employees.length; i++) {
                              if (_employees[i].id == employee.id) {
                                foundIndex = i;
                              }
                            }
                            return _buildCard(employee, foundIndex);
                          },
                        ),
                      ),
                    )
                  : _handleEmptyData()
        ],
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
                    if (_areSelectedEmployeesInWork()) {
                      showHint(context, getTranslated(context, 'someOfSelectedEmployeesAreInWork') + ' ', getTranslated(context, 'ifYouWantToFillTimeManuallyPleaseFirstStopTheirWork'));
                      return;
                    }
                    if (_workplaces.isEmpty) {
                      showHint(context, getTranslated(context, 'noWorkplaces') + ' ', getTranslated(context, 'goToWorkplacesSectionAndAddSomeWorkplaces'));
                      return;
                    }
                    _showUpdateHoursDialog();
                  },
                ),
              ),
              SizedBox(width: 1),
              Expanded(
                child: MaterialButton(
                  color: BLUE,
                  child: Image(image: AssetImage('images/white-play.png')),
                  onPressed: () {
                    if (_selectedIds.isEmpty) {
                      showHint(context, getTranslated(context, 'needToSelectRecords') + ' ', getTranslated(context, 'whichYouWantToUpdate'));
                      return;
                    }
                    if (_areSelectedEmployeesInWork()) {
                      showHint(context, getTranslated(context, 'someOfSelectedEmployeesAreInWork') + ' ', getTranslated(context, 'ifYouWantToStartWorkPleaseFirstStopTheirWork'));
                      return;
                    }
                    if (_workplaces.isEmpty) {
                      showHint(context, getTranslated(context, 'noWorkplaces') + ' ', getTranslated(context, 'goToWorkplacesSectionAndAddSomeWorkplaces'));
                      return;
                    }
                    _showChooseWorkplaceDialog(getTranslated(this.context, 'chooseWorkplaceWhereSelectedEmployeesWillStartWork'), () => _handleCreateWorkTimeForEmployees());
                  },
                ),
              ),
              SizedBox(width: 1),
              Expanded(
                child: MaterialButton(
                  color: BLUE,
                  child: Image(image: AssetImage('images/white-stop.png')),
                  onPressed: () {
                    if (_selectedIds.isEmpty) {
                      showHint(context, getTranslated(context, 'needToSelectRecords') + ' ', getTranslated(context, 'whichYouWantToUpdate'));
                      return;
                    }
                    if (_areSelectedEmployeesNotInWork()) {
                      showHint(context, getTranslated(context, 'someOfSelectedEmployeesAreNotInWork') + ' ', getTranslated(context, 'ifYouWantToStopWorkPleaseFirstStartTheirWork'));
                      return;
                    }
                    _showPauseWorkDialog();
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
                      icon20Red(Icons.close),
                    ],
                  ),
                  onPressed: () {
                    if (_selectedIds.isEmpty) {
                      showHint(context, getTranslated(context, 'needToSelectRecords') + ' ', getTranslated(context, 'whichYouWantToUpdate'));
                      return;
                    }
                    if (_workplaces.isEmpty) {
                      showHint(context, getTranslated(context, 'noWorkplaces') + ' ', getTranslated(context, 'goToWorkplacesSectionAndAddSomeWorkplaces'));
                      return;
                    }
                    _showDeleteWorkDialog();
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
          IconsLegendUtil.buildImageRow('images/hours.png', getTranslated(context, 'manualSettingOfWorkingTimes')),
          IconsLegendUtil.buildImageRow('images/play.png', getTranslated(context, 'startingWork')),
          IconsLegendUtil.buildImageRow('images/stop.png', getTranslated(context, 'stoppingWork')),
          IconsLegendUtil.buildImageWithIconRow('images/hours.png', icon20Red(Icons.close), getTranslated(context, 'deletingWork')),
        ],
      ),
    );
  }

  bool _areSelectedEmployeesInWork() {
    for (var employee in _selectedEmployees) {
      if (employee.workStatus == 'In progress') {
        return true;
      }
    }
    return false;
  }

  bool _areSelectedEmployeesNotInWork() {
    for (var employee in _selectedEmployees) {
      if (employee.workStatus != 'In progress' || employee.workStatus == 'Done') {
        return true;
      }
    }
    return false;
  }

  void _showUpdateHoursDialog() async {
    callendarroDialog(context).then((dates) {
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
                    Padding(padding: EdgeInsets.only(top: 50), child: text20Blue(getTranslated(context, 'workTimeUpperCase'))),
                    SizedBox(height: 20),
                    text17Black(getTranslated(context, 'startWorkTimeFrom')),
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
                    text17Black(getTranslated(context, 'finishWorkTimeTo')),
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
                              textCenter20Blue(title),
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
                                        widget: textBlack(_workplaces[i].name),
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
    CreateWorkTimeDto dto = new CreateWorkTimeDto(
      workplaceId: _workplaces[_chosenIndex].id,
      startTime: startTime,
      endTime: endTime,
    );
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _workTimeService.saveByEmployeeIdsAndDates(CollectionUtil.removeBracketsFromSet(_selectedIds), CollectionUtil.removeBracketsFromSet(dates.toSet()), dto).then((value) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        _uncheckAll();
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

  void _handleCreateWorkTimeForEmployees() {
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _workTimeService.startByEmployeeIdsAndWorkplaceId(CollectionUtil.removeBracketsFromSet(_selectedIds), _workplaces[_chosenIndex].id).then((value) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        _uncheckAll();
        _refresh();
        Navigator.pop(context);
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'workHasBeenStartedSuccessfullyForSelectedEmployees'));
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
      });
    });
  }

  _showPauseWorkDialog() {
    DialogUtil.showConfirmationDialog(
      context: context,
      title: getTranslated(context, 'confirmation'),
      content: getTranslated(context, 'pauseWorkForSelectedEmployeesConfirmation'),
      isBtnTapped: _isPauseButtonTapped,
      agreeFun: () => _isPauseButtonTapped ? null : _pauseSelectedEmployeesWork(),
    );
  }

  _pauseSelectedEmployeesWork() {
    setState(() => _isPauseButtonTapped = true);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _workTimeService.finishByEmployeeIds(CollectionUtil.removeBracketsFromSet(_selectedIds)).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        _uncheckAll();
        _refresh();
        Navigator.pop(context);
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'workHasBeenStoppedSuccessfullyForSelectedEmployees'));
        setState(() => _isPauseButtonTapped = false);
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        setState(() => _isPauseButtonTapped = false);
      });
    });
  }

  void _showDeleteWorkDialog() async {
    callendarroDialog(context).then((dates) {
      if (dates == null) {
        return;
      }
      DialogUtil.showConfirmationDialog(
        context: this.context,
        title: getTranslated(this.context, 'confirmation'),
        content: getTranslated(this.context, 'deleteWorkConfirmation'),
        isBtnTapped: _isDeleteWorkButtonTapped,
        agreeFun: () => _isDeleteWorkButtonTapped ? null : _handleDeleteWork(dates),
      );
    });
  }

  _handleDeleteWork(List<String> dates) {
    setState(() => _isDeleteWorkButtonTapped = true);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _workTimeService.deleteByEmployeeIdsAndDates(CollectionUtil.removeBracketsFromSet(_selectedIds), CollectionUtil.removeBracketsFromSet(dates.toSet())).then((value) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        _uncheckAll();
        _refresh();
        Navigator.pop(context);
        setState(() => _isDeleteWorkButtonTapped = false);
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'workHasBeenSuccessfullyDeleted'));
      });
    }).catchError(
      (onError) {
        Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
          DialogUtil.showErrorDialog(this.context, getTranslated(this.context, 'somethingWentWrong'));
          setState(() => _isDeleteWorkButtonTapped = false);
        });
      },
    );
  }

  Widget _buildCard(EmployeeWorkTimeDto employee, int foundIndex) {
    String name = employee.name;
    String surname = employee.surname;
    String gender = employee.gender;
    String nationality = employee.nationality;
    return Card(
      color: WHITE,
      child: Container(
        color: BRIGHTER_BLUE,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Ink(
              width: MediaQuery.of(context).size.width * 0.15,
              height: calculateInkWidth(employee),
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
                        _selectedEmployees.add(_employees[foundIndex]);
                      } else {
                        _selectedIds.remove(_employees[foundIndex].id);
                        _selectedEmployees.removeWhere((e) => e.id == _employees[foundIndex].id);
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
            SizedBox(width: 5),
            Expanded(
              child: InkWell(
                onTap: () => NavigatorUtil.navigate(this.context, EmployeeProfilePage(_model, employee.id, name, surname, gender, nationality)),
                child: Ink(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        text20Black((name + ' ' + surname).length > 30 ? (name + ' ' + surname).substring(0, 30) + '... ' + LanguageUtil.findFlagByNationality(nationality) : (name + ' ' + surname) + ' ' + LanguageUtil.findFlagByNationality(nationality)),
                        _handleWorkStatus(MainAxisAlignment.start, employee.workStatus, employee.workplace, employee.timeWorkedToday, employee.timeOfStartWork, employee.additionalInformation, employee.yesterdayAdditionalInformation),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double calculateInkWidth(EmployeeWorkTimeDto employee) {
    double inkWidth = 0;
    switch (employee.workStatus) {
      case 'Done':
        inkWidth = 96;
        break;
      case 'In progress':
        inkWidth = 96;
        break;
      default:
        inkWidth = 46;
        break;
    }
    if (employee.additionalInformation != null || employee.yesterdayAdditionalInformation != null) {
      inkWidth += 20;
    }
    return inkWidth;
  }

  Widget _handleWorkStatus(MainAxisAlignment alignment, String workStatus, String workplace, String timeWorkedToday, String timeOfStartWork, String additionalInformation, String yesterdayAdditionalInformation) {
    switch (workStatus) {
      case 'Done':
        return Column(
          children: [
            Row(
              mainAxisAlignment: alignment,
              children: <Widget>[textBlackBold(getTranslated(context, 'status') + ': '), iconGreen(Icons.check), textGreenBold(getTranslated(context, 'workIsDoneStatus'))],
            ),
            Row(
              mainAxisAlignment: alignment,
              children: <Widget>[textBlackBold(getTranslated(context, 'timeWorkedToday') + ': '), textGreenBold(timeWorkedToday)],
            ),
            Row(
              mainAxisAlignment: alignment,
              children: <Widget>[textBlackBold(getTranslated(context, 'workplace') + ': '), textBlack(workplace)],
            ),
            additionalInformation != null || yesterdayAdditionalInformation != null ? _handleAdditionalInfo(MainAxisAlignment.start, additionalInformation, yesterdayAdditionalInformation) : SizedBox(height: 0),
          ],
        );
      case 'In progress':
        return Column(
          children: [
            Row(
              mainAxisAlignment: alignment,
              children: <Widget>[textBlackBold(getTranslated(context, 'status') + ': '), iconOrange(Icons.timer), textOrangeBold(getTranslated(context, 'workIsInProgress'))],
            ),
            Row(
              mainAxisAlignment: alignment,
              children: <Widget>[textBlackBold(getTranslated(context, 'timeOfStartWork') + ': '), textBlack(timeOfStartWork)],
            ),
            Row(
              mainAxisAlignment: alignment,
              children: <Widget>[textBlackBold(getTranslated(context, 'workplace') + ': '), textBlack(workplace)],
            ),
            additionalInformation != null || yesterdayAdditionalInformation != null ? _handleAdditionalInfo(MainAxisAlignment.start, additionalInformation, yesterdayAdditionalInformation) : SizedBox(height: 0),
          ],
        );
      default:
        return Column(
          children: [
            Row(
              mainAxisAlignment: alignment,
              children: <Widget>[
                textBlackBold(getTranslated(context, 'status') + ': '),
                iconRed(Icons.remove),
                textRedBold(getTranslated(context, 'workDoNotStarted')),
              ],
            ),
            additionalInformation != null || yesterdayAdditionalInformation != null ? _handleAdditionalInfo(MainAxisAlignment.start, additionalInformation, yesterdayAdditionalInformation) : SizedBox(height: 0),
          ],
        );
    }
  }

  Widget _handleAdditionalInfo(MainAxisAlignment alignment, String additionalInfo, String yesterdayAdditionalInfo) {
    return Column(
      children: [
        additionalInfo != null
            ? Row(
                mainAxisAlignment: alignment,
                children: <Widget>[
                  textRedBold(getTranslated(context, 'todayAdditionalInfo') + ': '),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    icon: iconRed(Icons.search),
                    onPressed: () => DialogUtil.showScrollableDialog(
                      context,
                      getTranslated(context, 'todayAdditionalInfo'),
                      additionalInfo,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: alignment,
                children: <Widget>[
                  textRedBold(getTranslated(context, 'yesterdayAdditionalInfo') + ': '),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    icon: iconRed(Icons.search),
                    onPressed: () => DialogUtil.showScrollableDialog(
                      context,
                      getTranslated(context, 'yesterdayAdditionalInfo'),
                      yesterdayAdditionalInfo,
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _handleEmptyData() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Align(
            alignment: Alignment.center,
            child: text20BlueBold(getTranslated(context, 'noEmployees')),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Align(
            alignment: Alignment.center,
            child: textCenter19Black(getTranslated(context, 'youHaveNoEmployees')),
          ),
        ),
      ],
    );
  }

  Future<Null> _refresh() {
    return _employeeViewService.findAllByGroupIdForWorkTimeView(_model.groupId).then((res) {
      setState(() {
        _employees = res;
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

  void _uncheckAll() {
    _selectedIds.clear();
    _selectedEmployees.clear();
    _isChecked = false;
    List<bool> l = new List();
    _checked.forEach((b) => l.add(false));
    _checked = l;
  }
}
