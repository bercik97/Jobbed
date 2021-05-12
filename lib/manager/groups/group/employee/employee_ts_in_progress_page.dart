import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:jobbed/api/piecework/service/piecework_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:jobbed/api/work_time/dto/create_work_time_dto.dart';
import 'package:jobbed/api/work_time/service/work_time_service.dart';
import 'package:jobbed/api/workday/dto/workday_dto.dart';
import 'package:jobbed/api/workday/service/workday_service.dart';
import 'package:jobbed/api/workplace/dto/workplace_dto.dart';
import 'package:jobbed/api/workplace/service/workplace_service.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/groups/group/piecework/manage/add_piecework_page.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/collection_util.dart';
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

import '../../../shared/group_model.dart';
import '../../../shared/manager_app_bar.dart';

class EmployeeTsInProgressPage extends StatefulWidget {
  final GroupModel _model;
  final int _employeeId;
  final String _name;
  final String _surname;
  final String _gender;
  final String _nationality;
  final TimesheetForEmployeeDto timesheet;

  const EmployeeTsInProgressPage(this._model, this._employeeId, this._name, this._surname, this._gender, this._nationality, this.timesheet);

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

  int _employeeId;
  String _name;
  String _surname;
  String _gender;
  String _nationality;
  TimesheetForEmployeeDto _timesheet;

  Set<int> selectedIds = new LinkedHashSet();
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
    this._employeeId = widget._employeeId;
    this._name = widget._name;
    this._surname = widget._surname;
    this._gender = widget._gender;
    this._nationality = widget._nationality;
    this._timesheet = widget.timesheet;
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
    return Scaffold(
      backgroundColor: WHITE,
      appBar: managerAppBar(context, _user, getTranslated(context, 'workdays'), () => Navigator.pop(context)),
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
                        child: text17BlackBold(_name + ' ' + _surname + ' ' + LanguageUtil.findFlagByNationality(_nationality)),
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
                    if (selectedIds.isEmpty) {
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
                      NavigatorUtil.navigate(context, AddPieceworkPage(_model, null, null, selectedIds));
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
          IconsLegendUtil.buildIconRow(
              Row(
                children: [
                  iconBlack(Icons.search),
                  iconOrange(Icons.warning_amber_outlined),
                ],
              ),
              getTranslated(context, 'workTimeWithAdditionalInformation')),
        ],
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
            title: textBlackBold(getTranslated(context, 'shortNumber')),
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
    var additionalInfo = workdays[index].workTimes.firstWhere((element) => element.additionalInfo != null, orElse: () => null);
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
            child: workdays[index].workTimes != null && workdays[index].workTimes.isNotEmpty
                ? Row(
                    children: [
                      iconBlack(Icons.zoom_in),
                      additionalInfo != null ? iconOrange(Icons.warning_amber_outlined) : SizedBox(width: 0),
                    ],
                  )
                : Align(alignment: Alignment.center, child: text16Black('-')),
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

  void _handleSaveWorkTimesManually(String startTime, String endTime) {
    CreateWorkTimeDto dto = new CreateWorkTimeDto(
      workplaceId: _workplaces[_chosenIndex].id,
      startTime: startTime,
      endTime: endTime,
    );
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _workTimeService.saveByWorkdayIds(CollectionUtil.removeBracketsFromSet(selectedIds), dto).then((value) {
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
      agreeFun: () => _isDeleteWorkTimeButtonTapped ? null : _handleDeleteWorkTimes(),
    );
  }

  _handleDeleteWorkTimes() {
    setState(() => _isDeleteWorkTimeButtonTapped = true);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _workTimeService.deleteByWorkdayIds(CollectionUtil.removeBracketsFromSet(selectedIds)).then((value) {
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
      agreeFun: () => _isDeletePieceworkButtonTapped ? null : _handleDeletePiecework(),
    );
  }

  void _handleDeletePiecework() {
    setState(() => _isDeletePieceworkButtonTapped = true);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _pieceworkService.deleteAllByWorkdayIds(CollectionUtil.removeBracketsFromSet(selectedIds)).then((res) {
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
                                        DataCell(text16Black(pieceworks[i].serviceName)),
                                        DataCell(Align(alignment: Alignment.center, child: text16Black(pieceworks[i].quantity.toString()))),
                                        DataCell(Align(alignment: Alignment.center, child: text16Black(pieceworks[i].moneyForEmployee.toString()))),
                                        DataCell(Align(alignment: Alignment.center, child: text16Black(pieceworks[i].moneyForCompany.toString()))),
                                        DataCell(
                                          IconButton(
                                            icon: iconRed(Icons.delete),
                                            onPressed: () {
                                              DialogUtil.showConfirmationDialog(
                                                context: context,
                                                title: getTranslated(context, 'confirmation'),
                                                content: getTranslated(context, 'deletingSelectedPieceworkServiceConfirmation'),
                                                isBtnTapped: _isDeletePieceworkServiceButtonTapped,
                                                agreeFun: () => _isDeletePieceworkServiceButtonTapped ? null : _handleDeletePieceworkService(workdayId, pieceworks[i].serviceName),
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
                                  DataColumn(label: textBlackBold(getTranslated(context, 'from'))),
                                  DataColumn(label: textBlackBold(getTranslated(context, 'to'))),
                                  DataColumn(label: textBlackBold(getTranslated(context, 'sum'))),
                                  DataColumn(label: textBlackBold(getTranslated(context, 'information'))),
                                  DataColumn(label: textBlackBold(getTranslated(context, 'workplace'))),
                                  DataColumn(label: textBlackBold('')),
                                ],
                                rows: [
                                  for (int i = 0; i < workTimes.length; i++)
                                    DataRow(
                                      cells: [
                                        DataCell(text16Black(workTimes[i].startTime.toString())),
                                        DataCell(text16Black(workTimes[i].endTime != null ? workTimes[i].endTime.toString() : '-')),
                                        DataCell(text16Black(workTimes[i].totalTime != null ? workTimes[i].totalTime.toString() : '-')),
                                        workTimes[i].additionalInfo != null
                                            ? DataCell(
                                                Row(
                                                  children: [
                                                    iconBlack(Icons.search),
                                                    iconOrange(Icons.warning_amber_outlined),
                                                  ],
                                                ),
                                                onTap: () => DialogUtil.showScrollableDialog(
                                                  context,
                                                  getTranslated(context, 'additionalInfo'),
                                                  workTimes[i].additionalInfo.toString(),
                                                ),
                                              )
                                            : DataCell(textBlack(getTranslated(context, 'empty'))),
                                        DataCell(text16Black(workTimes[i].workplaceName.toString())),
                                        DataCell(
                                          IconButton(
                                            icon: iconRed(Icons.delete),
                                            onPressed: () {
                                              DialogUtil.showConfirmationDialog(
                                                context: context,
                                                title: getTranslated(context, 'confirmation'),
                                                content: getTranslated(context, 'deletingSelectedWorkTimeConfirmation'),
                                                isBtnTapped: _isDeleteWorkTimeButtonTapped,
                                                agreeFun: () => _isDeleteWorkTimeButtonTapped ? null : _handleDeleteWorkTime(workTimes[i].id),
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
