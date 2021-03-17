import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:jobbed/api/piecework/service/piecework_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:jobbed/api/work_time/service/work_time_service.dart';
import 'package:jobbed/api/workday/dto/workday_dto.dart';
import 'package:jobbed/api/workday/service/workday_service.dart';
import 'package:jobbed/api/workplace/dto/workplace_dto.dart';
import 'package:jobbed/api/workplace/service/workplace_service.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/groups/group/piecework/manage/add_piecework_for_selected_workdays.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/data_table_util.dart';
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
import 'package:jobbed/shared/widget/texts.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

import '../../../../shared/libraries/constants.dart';
import '../../../shared/group_model.dart';
import '../../../shared/manager_app_bar.dart';

class EmployeeTsInProgressPage extends StatefulWidget {
  final GroupModel _model;
  final String _employeeInfo;
  final int _employeeId;
  final String _employeeNationality;
  final TimesheetForEmployeeDto timesheet;
  final String _avatarPath;

  const EmployeeTsInProgressPage(this._model, this._employeeInfo, this._employeeId, this._employeeNationality, this.timesheet, this._avatarPath);

  @override
  _EmployeeTsInProgressPageState createState() => _EmployeeTsInProgressPageState();
}

class _EmployeeTsInProgressPageState extends State<EmployeeTsInProgressPage> {
  final TextEditingController _fromHoursController = new TextEditingController();
  final TextEditingController _fromMinutesController = new TextEditingController();
  final TextEditingController _toHoursController = new TextEditingController();
  final TextEditingController _toMinutesController = new TextEditingController();

  GroupModel _model;
  User _user;

  String _employeeInfo;
  int _employeeId;
  String _employeeNationality;
  TimesheetForEmployeeDto _timesheet;
  String _avatarPath;

  Set<int> selectedIds = new Set();
  List<bool> _checked = new List();
  List<WorkdayDto> workdays = new List();

  bool _loading = false;

  List<WorkplaceDto> _workplaces = new List();
  List<int> _workplacesRadioValues = new List();
  int _chosenIndex = -1;
  bool _isChoseWorkplaceBtnDisabled = true;

  bool _isDeletePieceworkServiceButtonTapped = false;
  bool _isDeleteWorkTimeButtonTapped = false;
  bool _isDeletePieceworkButtonTapped = false;

  WorkdayService _workdayService;
  PieceworkService _pieceworkService;
  WorkTimeService _workTimeService;
  WorkplaceService _workplaceService;

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._workdayService = ServiceInitializer.initialize(context, _user.authHeader, WorkdayService);
    this._pieceworkService = ServiceInitializer.initialize(context, _user.authHeader, PieceworkService);
    this._workTimeService = ServiceInitializer.initialize(context, _user.authHeader, WorkTimeService);
    this._workplaceService = ServiceInitializer.initialize(context, _user.authHeader, WorkplaceService);
    this._employeeInfo = widget._employeeInfo;
    this._employeeId = widget._employeeId;
    this._employeeNationality = widget._employeeNationality;
    this._timesheet = widget.timesheet;
    this._avatarPath = widget._avatarPath;
    super.initState();
    _loading = true;
    _workdayService.findAllByTimesheetId(_timesheet.id).then((res) {
      setState(() {
        workdays = res;
        workdays.forEach((e) => _checked.add(false));
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
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(primarySwatch: MaterialColor(0xff2BADFF, BLUE_RGBO)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: WHITE,
        appBar: managerAppBar(context, _user, getTranslated(context, 'workdays') + ' - ' + getTranslated(context, STATUS_IN_PROGRESS), () => Navigator.pop(context)),
        body: RefreshIndicator(
          color: WHITE,
          backgroundColor: BLUE,
          onRefresh: _refresh,
          child: Column(
            children: <Widget>[
              Container(
                color: BRIGHTER_BLUE,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: ListTile(
                    leading: Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: icon30Orange(Icons.arrow_circle_up),
                    ),
                    title: text17BlackBold(_timesheet.year.toString() + ' ' + MonthUtil.translateMonth(context, _timesheet.month)),
                    subtitle: Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft,
                          child: text17BlackBold(_employeeInfo != null ? utf8.decode(_employeeInfo.runes.toList()) + ' ' + LanguageUtil.findFlagByNationality(_employeeNationality) : getTranslated(context, 'empty')),
                        ),
                        Row(
                          children: <Widget>[
                            text17BlackBold(getTranslated(this.context, 'accord') + ': '),
                            text16Black(_timesheet.totalMoneyForPieceworkForEmployee.toString() + ' PLN'),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            text17BlackBold(getTranslated(this.context, 'time') + ': '),
                            text16Black(_timesheet.totalMoneyForTimeForEmployee.toString() + ' PLN' + ' (' + _timesheet.totalTime + ')'),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            text17BlackBold(getTranslated(this.context, 'sum') + ': '),
                            text16Black(_timesheet.totalMoneyEarned.toString() + ' PLN'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _loading
                  ? circularProgressIndicator()
                  : Expanded(
                      child: Container(
                        child: HorizontalDataTable(
                          leftHandSideColumnWidth: 100,
                          rightHandSideColumnWidth: 385,
                          isFixedHeader: true,
                          headerWidgets: _buildTitleWidget(),
                          leftSideItemBuilder: _buildFirstColumnRow,
                          rightSideItemBuilder: _buildRightHandSideColumnRow,
                          itemCount: workdays.length,
                          rowSeparatorWidget: Divider(color: BLUE, height: 1.0, thickness: 0.0),
                          leftHandSideColBackgroundColor: WHITE,
                          rightHandSideColBackgroundColor: WHITE,
                        ),
                        height: MediaQuery.of(context).size.height,
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
                      if (selectedIds.isNotEmpty) {
                        _showUpdateWorkTimeDialog();
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
                        Image(image: AssetImage('images/white-hours.png')),
                        iconRed(Icons.close),
                      ],
                    ),
                    onPressed: () {
                      if (selectedIds.isNotEmpty) {
                        _showDeleteWorkTimeDialog();
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
                    child: Image(image: AssetImage('images/white-piecework.png')),
                    onPressed: () {
                      if (selectedIds.isNotEmpty) {
                        NavigatorUtil.navigate(
                            context,
                            AddPieceworkForSelectedWorkdays(
                              _model,
                              selectedIds.map((el) => el.toString()).toList(),
                              _employeeInfo,
                              _employeeId,
                              _employeeNationality,
                              _timesheet,
                              _avatarPath,
                            ));
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
                      if (selectedIds.isNotEmpty) {
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
          this.context,
          getTranslated(context, 'iconsLegend'),
          [
            IconsLegendUtil.buildIconRow(iconOrange(Icons.arrow_circle_up), getTranslated(context, 'tsInProgress')),
            IconsLegendUtil.buildIconRow(iconBlack(Icons.search), getTranslated(context, 'checkDetails')),
            IconsLegendUtil.buildImageRow('images/hours.png', getTranslated(context, 'settingHours')),
            IconsLegendUtil.buildImageWithIconRow('images/hours.png', iconRed(Icons.close), getTranslated(context, 'deletingWork')),
            IconsLegendUtil.buildImageRow('images/piecework.png', getTranslated(context, 'settingPiecework')),
            IconsLegendUtil.buildImageWithIconRow('images/piecework.png', iconRed(Icons.close), getTranslated(context, 'deletingPiecework')),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTitleWidget() {
    return [
      Container(
        height: 50,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 28),
          child: CheckboxListTile(
            contentPadding: EdgeInsets.only(left: 1),
            controlAffinity: ListTileControlAffinity.leading,
            title: textBlackBold(getTranslated(context, 'day')),
            subtitle: textBlackBold(' '),
            activeColor: BLUE,
            checkColor: WHITE,
            value: selectedIds.length == workdays.length,
            onChanged: (bool value) {
              setState(() {
                _checked.clear();
                if (value) {
                  selectedIds.addAll(workdays.map((e) => e.id));
                  workdays.forEach((e) => _checked.add(true));
                } else {
                  selectedIds.clear();
                  workdays.forEach((e) => _checked.add(false));
                }
              });
            },
          ),
        ),
      ),
      DataTableUtil.buildTitleItemWidget(getTranslated(context, 'hours'), 75),
      DataTableUtil.buildTitleItemWidget(getTranslated(context, 'accord'), 50),
      DataTableUtil.buildTitleItemWidget(getTranslated(context, 'time'), 50),
      DataTableUtil.buildTitleItemWidgetWithRow(getTranslated(context, 'money'), getTranslated(context, 'employee'), getTranslated(context, 'net'), 80),
      DataTableUtil.buildTitleItemWidgetWithRow(getTranslated(context, 'money'), getTranslated(context, 'company'), getTranslated(context, 'gross'), 80),
    ];
  }

  Widget _buildFirstColumnRow(BuildContext context, int index) {
    return Container(
      height: 50,
      color: BRIGHTER_BLUE,
      child: CheckboxListTile(
        contentPadding: EdgeInsets.only(left: 1),
        controlAffinity: ListTileControlAffinity.leading,
        title: text16Black(workdays[index].number.toString()),
        activeColor: BLUE,
        checkColor: WHITE,
        value: _checked[index],
        onChanged: (bool value) {
          setState(() {
            _checked[index] = value;
            if (value) {
              selectedIds.add(workdays[index].id);
            } else {
              selectedIds.remove(workdays[index].id);
            }
          });
        },
      ),
    );
  }

  Widget _buildRightHandSideColumnRow(BuildContext context, int index) {
    return Row(
      children: <Widget>[
        Container(
          child: Align(alignment: Alignment.center, child: text16Black(workdays[index].hours)),
          width: 75,
          height: 50,
        ),
        InkWell(
          onTap: () => _showScrollablePieceworksDialog(this.context, workdays[index].id, workdays[index].pieceworks),
          child: Ink(
            child: workdays[index].pieceworks != null && workdays[index].pieceworks.isNotEmpty ? iconBlack(Icons.zoom_in) : Align(alignment: Alignment.center, child: text16Black('-')),
            width: 50,
            height: 50,
          ),
        ),
        InkWell(
          onTap: () => _showScrollableWorkTimesDialog(this.context, workdays[index].workTimes),
          child: Ink(
            child: workdays[index].workTimes != null && workdays[index].workTimes.isNotEmpty ? iconBlack(Icons.zoom_in) : Align(alignment: Alignment.center, child: text16Black('-')),
            width: 50,
            height: 50,
          ),
        ),
        Container(
          child: Align(alignment: Alignment.center, child: text16Black(workdays[index].totalMoneyForEmployee)),
          width: 80,
          height: 50,
        ),
        Container(
          child: Align(alignment: Alignment.center, child: text16Black(workdays[index].totalMoneyForCompany)),
          width: 80,
          height: 50,
        ),
      ],
    );
  }

  void _showUpdateWorkTimeDialog() async {
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
                  text16Black(getTranslated(context, 'setWorkTimeForEmployee')),
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
                                max: 24,
                                onIncrement: (value) {
                                  if (value > 24) {
                                    setState(() => value = 24);
                                  }
                                },
                                onSubmitted: (value) {
                                  if (value >= 24) {
                                    setState(() => _fromHoursController.text = 24.toString());
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
                                max: 24,
                                onIncrement: (value) {
                                  if (value > 24) {
                                    setState(() => value = 24);
                                  }
                                },
                                onSubmitted: (value) {
                                  if (value >= 24) {
                                    setState(() => _toHoursController.text = 24.toString());
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
                            ToastUtil.showErrorToast(getTranslated(context, 'givenValueIsNotANumber'));
                            return;
                          }
                          String validationMsg = ValidatorUtil.validateSettingManuallyWorkTimes(fromHours, fromMinutes, toHours, toMinutes, context);
                          if (validationMsg != null) {
                            ToastUtil.showErrorToast(validationMsg);
                            return;
                          }
                          String startTime = fromHours.toString() + ':' + fromMinutes.toString() + ':' + '00';
                          String endTime = toHours.toString() + ':' + toMinutes.toString() + ':' + '00';
                          _showChooseWorkplaceDialog(getTranslated(this.context, 'chooseWorkplace'), () => _handleSaveWorkTimesManually(startTime, endTime));
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
                                        title: utf8.decode(_workplaces[i].name.runes.toList()),
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

  void _handleSaveWorkTimesManually(String startTime, String endTime) {
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _workTimeService.saveForWorkdays(selectedIds.map((el) => el.toString()).toList(), _workplaces[_chosenIndex].id, startTime, endTime).then((value) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        _refresh();
        Navigator.pop(context);
        Navigator.pop(context);
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'workingTimeHasBeenSuccessfullySetForSelectedDays'));
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
      });
    });
  }

  void _showDeleteWorkTimeDialog() async {
    DialogUtil.showConfirmationDialog(
      context: this.context,
      title: getTranslated(this.context, 'confirmation'),
      content: getTranslated(this.context, 'deleteWorkForSingleEmployeeConfirmation'),
      isBtnTapped: _isDeleteWorkTimeButtonTapped,
      fun: () => _isDeleteWorkTimeButtonTapped ? null : _handleDeleteWorkTimes(),
    );
  }

  _handleDeleteWorkTimes() {
    setState(() => _isDeleteWorkTimeButtonTapped = true);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _workTimeService.deleteByWorkdayIds(selectedIds.map((el) => el.toString()).toList()).then((value) {
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

  void _showDeletePiecework() async {
    DialogUtil.showConfirmationDialog(
      context: context,
      title: getTranslated(context, 'confirmation'),
      content: getTranslated(context, 'deletingPieceworkForSelectedDaysConfirmation'),
      isBtnTapped: _isDeletePieceworkButtonTapped,
      fun: () => _isDeletePieceworkButtonTapped ? null : _handleDeletePiecework(selectedIds.map((el) => el.toString()).toList()),
    );
  }

  void _handleDeletePiecework(List<String> ids) {
    setState(() => _isDeletePieceworkButtonTapped = true);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _workdayService.deletePieceworkByIds(ids).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        _refresh();
        Navigator.of(context).pop();
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'pieceworkForSelectedDaysDeleted'));
        setState(() => _isDeletePieceworkButtonTapped = false);
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        setState(() => _isDeletePieceworkButtonTapped = false);
      });
    });
  }

  void _showScrollablePieceworksDialog(BuildContext context, num workdayId, List pieceworks) {
    if (pieceworks == null || pieceworks.isEmpty) {
      return;
    }
    showGeneralDialog(
      context: context,
      barrierColor: WHITE.withOpacity(0.95),
      barrierDismissible: false,
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[
                        text20BlueBold(getTranslated(context, 'pieceworkReports')),
                        SizedBox(height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Theme(
                              data: Theme.of(context).copyWith(dividerColor: BLUE),
                              child: DataTable(
                                columnSpacing: 10,
                                columns: [
                                  DataColumn(label: textBlackBold('No.')),
                                  DataColumn(label: textBlackBold(getTranslated(context, 'serviceName'))),
                                  DataColumn(label: textBlackBold(getTranslated(context, 'quantity'))),
                                  DataColumn(
                                    label: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        textBlackBold(getTranslated(context, 'price')),
                                        text12Black('(' + getTranslated(context, 'employee') + ')'),
                                      ],
                                    ),
                                  ),
                                  DataColumn(
                                    label: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        textBlackBold(getTranslated(context, 'price')),
                                        text12Black('(' + getTranslated(context, 'company') + ')'),
                                      ],
                                    ),
                                  ),
                                  DataColumn(label: textBlackBold('')),
                                ],
                                rows: [
                                  for (int i = 0; i < pieceworks.length; i++)
                                    DataRow(
                                      cells: [
                                        DataCell(text16Black((i + 1).toString())),
                                        DataCell(text16Black(utf8.decode(pieceworks[i].service.runes.toList()))),
                                        DataCell(Align(alignment: Alignment.center, child: text16Black(pieceworks[i].quantity.toString()))),
                                        DataCell(Align(alignment: Alignment.center, child: text16Black(pieceworks[i].priceForEmployee.toString()))),
                                        DataCell(Align(alignment: Alignment.center, child: text16Black(pieceworks[i].priceForCompany.toString()))),
                                        DataCell(
                                          IconButton(
                                            icon: iconRed(Icons.delete),
                                            onPressed: () {
                                              DialogUtil.showConfirmationDialog(
                                                context: context,
                                                title: getTranslated(context, 'confirmation'),
                                                content: getTranslated(context, 'deletingSelectedPieceworkServiceConfirmation'),
                                                isBtnTapped: _isDeletePieceworkServiceButtonTapped,
                                                fun: () => _isDeletePieceworkServiceButtonTapped ? null : _handleDeletePieceworkService(workdayId, pieceworks[i].service),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: 60,
                          child: MaterialButton(
                            elevation: 0,
                            height: 50,
                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[iconWhite(Icons.close)],
                            ),
                            color: Colors.red,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleDeletePieceworkService(num workdayId, String serviceName) {
    setState(() => _isDeletePieceworkServiceButtonTapped = true);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _pieceworkService.deleteByWorkdayIdAndServiceName(workdayId, serviceName).then((value) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'successfullyDeletedPieceworkService'));
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        _refresh();
        setState(() => _isDeletePieceworkServiceButtonTapped = false);
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        setState(() => _isDeletePieceworkServiceButtonTapped = false);
      });
    });
  }

  void _showScrollableWorkTimesDialog(BuildContext context, List workTimes) {
    if (workTimes == null || workTimes.isEmpty) {
      return;
    }
    showGeneralDialog(
      context: context,
      barrierColor: WHITE.withOpacity(0.95),
      barrierDismissible: false,
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[
                        text20BlueBold(getTranslated(context, 'workTimes')),
                        SizedBox(height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Theme(
                              data: Theme.of(context).copyWith(dividerColor: BLUE),
                              child: DataTable(
                                columnSpacing: 10,
                                columns: [
                                  DataColumn(label: textBlackBold('No.')),
                                  DataColumn(label: textBlackBold(getTranslated(context, 'from'))),
                                  DataColumn(label: textBlackBold(getTranslated(context, 'to'))),
                                  DataColumn(label: textBlackBold(getTranslated(context, 'sum'))),
                                  DataColumn(label: textBlackBold(getTranslated(context, 'workplace'))),
                                  DataColumn(label: textBlackBold('')),
                                ],
                                rows: [
                                  for (int i = 0; i < workTimes.length; i++)
                                    DataRow(
                                      cells: [
                                        DataCell(text16Black((i + 1).toString())),
                                        DataCell(text16Black(workTimes[i].startTime.toString())),
                                        DataCell(text16Black(workTimes[i].endTime != null ? workTimes[i].endTime.toString() : '-')),
                                        DataCell(text16Black(workTimes[i].totalTime != null ? workTimes[i].totalTime.toString() : '-')),
                                        DataCell(text16Black(utf8.decode(workTimes[i].workplaceName.toString().runes.toList()))),
                                        DataCell(
                                          IconButton(
                                            icon: iconRed(Icons.delete),
                                            onPressed: () {
                                              DialogUtil.showConfirmationDialog(
                                                context: context,
                                                title: getTranslated(context, 'confirmation'),
                                                content: getTranslated(context, 'deletingSelectedWorkTimeConfirmation'),
                                                isBtnTapped: _isDeleteWorkTimeButtonTapped,
                                                fun: () => _isDeleteWorkTimeButtonTapped ? null : _handleDeleteWorkTime(workTimes[i].id),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: 60,
                          child: MaterialButton(
                            elevation: 0,
                            height: 50,
                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[iconWhite(Icons.close)],
                            ),
                            color: Colors.red,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleDeleteWorkTime(num workTimeId) {
    setState(() => _isDeleteWorkTimeButtonTapped = true);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _workTimeService.deleteById(workTimeId).then((value) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'successfullyDeletedWorkTime'));
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        _refresh();
        setState(() => _isDeleteWorkTimeButtonTapped = false);
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        setState(() => _isDeleteWorkTimeButtonTapped = false);
      });
    });
  }

  Future<Null> _refresh() {
    return _workdayService.findAllByTimesheetId(_timesheet.id).then((res) {
      setState(() {
        workdays = res;
        workdays.forEach((e) => _checked.add(false));
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
}
